# frozen_string_literal: true

require "nokogiri"
require "ostruct"
require "rufo"
require "html_press"
require "erb_parser"

module Phlexing
  class Converter
    include Helpers

    using ::Phlexing::Refinements::StringRefinements

    attr_accessor :html, :custom_elements, :erb_dependencies

    def self.convert(html, **options)
      new(html, **options).output
    end

    def self.suggest_name(html)
      converter = Phlexing::Converter.new(html)

      if converter.erb_dependencies.any?
        return "#{converter.erb_dependencies.first.gsub("@", "")}_component"
      end

      if converter.parsed
        first_element = converter.parsed.children.first

        if id = first_element.attributes.try(:[], "id")
          return "#{id.value.strip}_component" unless id.value.include?("<erb")
        end

        if classes = first_element.attributes.try(:[], "class")
          classes = classes.value.split(" ")
          return "#{classes[0]}_component" if classes.one?
        end

        return "#{first_element.name}_component" unless ["div", "span", "p"].include?(first_element.name)
      end

      "Component"
    end

    def initialize(html, **options)
      @html = html
      @buffer = StringIO.new
      @custom_elements = Set.new
      @erb_dependencies = Set.new
      @options = options
      handle_node
    end

    def register_erb_dependency(erb)
      erb.scan(/@\w+/).each do |dep|
        @erb_dependencies << dep
      end
    end

    def handle_text(node, level, newline: true)
      text = node.text

      if text.squish.empty? && text.length.positive?
        @buffer << indent(level)
        @buffer << whitespace(@options)

        text.strip!
      end

      if text.length.positive?
        @buffer << indent(level)

        if siblings?(node)
          @buffer << "text "
        end

        @buffer << quote(text)
        @buffer << "\n" if newline
      end
    end

    def handle_erb_element(node, level, newline: true)
      if erb_safe_output?(node)
        @buffer << "raw "
        @buffer << node.text.from(1)
        @buffer << "\n" if newline

        register_erb_dependency(node.text.from(1))
        return
      end

      if erb_interpolation?(node) && node.parent.children.count > 1
        if node.text.length >= 24
          @buffer << "text("
          @buffer << node.text
          @buffer << ")"
        else
          @buffer << "text "
          @buffer << node.text
        end
      elsif erb_comment?(node)
        @buffer << "#"
        @buffer << node.text
      else
        @buffer << node.text
      end

      register_erb_dependency(node.text)

      @buffer << "\n" if newline
    end

    def handle_element(node, level)
      @buffer << (indent(level) + node_name(node) + handle_attributes(node))

      if node.children.any?
        if node.children.one? && text_node?(node.children.first) && node.text.length <= 32
          single_line_block {
            handle_text(node.children.first, 0, newline: false)
          }
        elsif node.children.one? && erb_interpolation?(node.children.first) && node.text.length <= 32
          single_line_block {
            handle_erb_element(node.children.first, 0, newline: false)
          }
        else
          multi_line_block(level) {
            handle_children(node, level)
          }
        end
      else
        @buffer << "\n"
      end
    end

    def handle_comment_node(node, level)
      @buffer << indent(level)
      @buffer << "comment "
      @buffer << quote(node.text.strip)
      @buffer << "\n"
    end

    def handle_children(node, level)
      node.children.each do |child|
        handle_node(child, level + 1)
      end
    end

    def handle_attributes(node)
      return "" if node.attributes.keys.none?

      b = StringIO.new

      node.attributes.each_value do |attribute|
        b << attribute.name.gsub("-", "_")
        b << ": "
        b << double_quote(attribute.value)
        b << ", " if node.attributes.values.last != attribute
      end

      if node.children.any?
        "(#{b.string.strip}) "
      else
        " #{b.string.strip}"
      end
    end

    def handle_node(node = parsed, level = 0)
      case node
      when Nokogiri::XML::Text
        handle_text(node, level)
      when Nokogiri::XML::Element
        if erb_node?(node)
          handle_erb_element(node, level)
        else
          handle_element(node, level)
        end

        @buffer << "\n" if level == 1
      when Nokogiri::HTML4::DocumentFragment
        handle_children(node, level)
      when Nokogiri::XML::Comment
        handle_comment_node(node, level)
      else
        @buffer << ("UNKNOWN#{node.class}")
      end

      @buffer.string
    end

    def parsed
      @parsed ||= Nokogiri::HTML.fragment(minified_erb)
    end

    def buffer
      Rufo::Formatter.format(@buffer.string.strip)
    rescue Rufo::SyntaxError
      @buffer.string.strip
    end

    def output
      buffer = StringIO.new

      if @options.fetch(:phlex_class, false)
        component_name = @options.fetch(:component_name, 'Component')
        component_name = "A#{component_name}" if component_name[0] == "0" || component_name[0].to_i != 0

        parent_component = @options.fetch(:parent_component, 'Phlex::HTML')
        parent_component = "A#{parent_component}" if parent_component[0] == "0" || parent_component[0].to_i != 0

        buffer << "class #{component_name}"
        buffer << "< #{parent_component}\n"

        if @erb_dependencies.any?
          buffer << indent(1)
          buffer << "def initialize("

          @erb_dependencies.each do |dep|
            buffer << "#{dep.gsub('@', '')}: "
            buffer << ", " if dep != @erb_dependencies.to_a.last
          end

          buffer << ")\n"

          @erb_dependencies.each do |dep|
            buffer << (indent(2) + "#{dep} = #{dep.gsub('@', '')}\n")
          end

          buffer << ("#{indent(1)}end\n")
        end

        @custom_elements.each do |element|
          buffer << (indent(1) + "register_element :#{element}\n")
        end

        buffer << ("#{indent(1)}def template\n")
        buffer << (indent(2) + @buffer.string)
        buffer << ("#{indent(1)}end\n")
        buffer << "end\n"
      else
        buffer << @buffer.string
      end

      Rufo::Formatter.format(buffer.string.strip)
    rescue Rufo::SyntaxError
      buffer.string.strip
    end

    def converted_erb
      ErbParser.transform_xml(html).gsub("\n", "").gsub("\r", "")
    rescue StandardError
      html
    end

    def minified_erb
      HtmlPress.press(converted_erb)
    rescue StandardError
      converted_erb
    end
  end
end

# frozen_string_literal: true

module Phlexing
  class TemplateGenerator
    using Refinements::StringRefinements

    include Helpers

    attr_accessor :converter, :out, :options

    def self.generate(converter, html)
      new(converter).generate(html)
    end

    def initialize(converter)
      @converter = converter
      @options = @converter.options
      @out = StringIO.new
    end

    def generate(html)
      document = Parser.parse(html)
      handle_node(document)

      Formatter.format(out.string.strip)
    end

    def handle_text(node, level, newline: true)
      text = node.text

      if text.squish.empty? && text.length.positive?
        out << indent(level)
        out << whitespace

        text.strip!
      end

      if text.length.positive?
        out << indent(level)

        if siblings?(node)
          out << "text "
        end

        out << quote(text)
        out << "\n" if newline
      end
    end

    def handle_erb_element(node, level, newline: true)
      if erb_safe_output?(node)
        out << "unsafe_raw "
        out << node.text.from(1)
        out << "\n" if newline

        return
      end

      if erb_interpolation?(node) && node.parent.children.count > 1
        if node.text.strip.start_with?("render")
          out << node.text
        elsif node.text.length >= 24
          out << "text("
          out << node.text
          out << ")"
        else
          out << "text "
          out << node.text
        end
      elsif erb_comment?(node)
        out << "#"
        out << node.text
      else
        out << node.text
      end

      out << "\n" if newline
    end

    def handle_element(node, level)
      out << (indent(level) + node_name(node) + handle_attributes(node))

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
        out << "\n"
      end
    end

    def handle_comment_node(node, level)
      out << indent(level)
      out << "comment "
      out << quote(node.text.strip)
      out << "\n"
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

    def handle_node(node, level = 0)
      case node
      when Nokogiri::XML::Text
        handle_text(node, level)
      when Nokogiri::XML::Element
        if erb_node?(node)
          handle_erb_element(node, level)
        else
          handle_element(node, level)
        end

        out << "\n" if level == 1
      when Nokogiri::HTML4::DocumentFragment
        handle_children(node, level)
      when Nokogiri::XML::Comment
        handle_comment_node(node, level)
      else
        out << ("UNKNOWN#{node.class}")
      end
    end
  end
end

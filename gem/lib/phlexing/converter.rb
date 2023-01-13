# frozen_string_literal: true

require "nokogiri"
require "ostruct"
require "rufo"
require "html_press"
require "erb_parser"

module Phlexing
  class ErbPart
    attr_accessor :html, :unescaped, :index, :replace_tag

    def initialize(html, unescaped, index)
      @html = html
      @unescaped = CGI.unescapeHTML(unescaped)
      @index = index
      @replace_tag = "{PHLEXING:ERB:INDEX:#{index}}"
    end
  end

  class MyErbParser
    REGEX_1 = /(<erb \w+=".+">(.+)<\/erb>)/
    REGEX_2 = /(<erb (?:(?: )*\w+="(?:(?: )*(?:\w)*(?: )*)*"(?: )*)*>(.+)<\/erb>)/
    TAG = /{PHLEXING:ERB:INDEX:\d+}/

    attr_accessor :parts, :initial_html, :html

    def initialize(html)
      @parts = []
      @initial_html = html
      @html = html
    end

    def scan
      @initial_html.scan(REGEX_2).each_with_index do |result, index|
        erb = result[0]
        unescaped = result[1]

        part = ErbPart.new(erb.strip, unescaped, index)
        @html = @html.gsub(erb, part.replace_tag)
        @parts << part
      end

      @html
    end
  end

  class Converter
    include Helpers

    using ::Phlexing::Refinements::StringRefinements

    attr_accessor :html, :custom_elements

    def self.convert(html, **options)
      new(html, **options).output
    end

    def initialize(html, **options)
      @html = html
      @buffer = StringIO.new
      @custom_elements = Set.new
      @options = options
      handle_node
    end

    def handle_text(node, level, newline: true)
      text = node.text

      if text.scan(MyErbParser::TAG).any?
        @my_erb_parser.parts.each do |part|
          if text.include?(part.replace_tag)
            text = text.gsub(%("#{part.replace_tag}"), part.unescaped.strip)
            text = text.gsub(%('#{part.replace_tag}'), part.unescaped.strip)
            text = text.gsub(part.replace_tag, part.unescaped.strip)
          end
        end
      end

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
      # binding.irb

      if erb_safe_output?(node)
        @buffer << "raw "
        @buffer << node.text.from(1)
        @buffer << "\n" if newline
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

        if attribute.value.scan(MyErbParser::TAG)
          @my_erb_parser.parts.each do |part|
            if attribute.value.include?(part.replace_tag)
              b << part.unescaped.strip
            end
          end
        else
          b << double_quote(attribute.value)
        end

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

        if node.text.scan(MyErbParser::TAG) && node.children.none?
          @my_erb_parser.parts.each do |part|
            if node.text.include?(part.replace_tag)
              element = Nokogiri.parse(part.html).root

              handle_node(element, level)
            end
          end
        else
          handle_text(node, level)
        end


      when Nokogiri::XML::Element

        if node.text.scan(MyErbParser::TAG) && node.children.none?
          @my_erb_parser.parts.each do |part|
            if node.text.include?(part.replace_tag)
              element = Nokogiri.parse(part.html).root

              handle_node(element, level)
            end
          end
        else
          if erb_node?(node)
            handle_erb_element(node, level)
          else
            handle_element(node, level)
          end
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
      @parsed ||= Nokogiri::HTML.fragment(erb_escaped_html)
    end

    def buffer
      string = @buffer.string.strip

      @my_erb_parser.parts.each do |part|
        # string = string.gsub(%("#{part.replace_tag}"), part.unescaped)
        string = string.gsub(part.replace_tag, part.unescaped)
      end

      Rufo::Formatter.format(string)
    rescue Rufo::SyntaxError
      @buffer.string.strip
    end

    def output
      buffer = StringIO.new

      if @options.fetch(:phlex_class, false)
        buffer << "class #{@options.fetch(:component_name, 'MyComponent')}"
        buffer << "< #{@options.fetch(:parent_component, 'Phlex::HTML')}\n"

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
      HtmlPress.press(converted_erb).gsub("</erb>", "</erb>\n")
    rescue StandardError
      converted_erb
    end

    def erb_escaped_html
      @my_erb_parser = MyErbParser.new(minified_erb)
      @my_erb_parser.scan
    rescue StandardError
      minified_erb
    end
  end
end

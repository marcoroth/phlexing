require "nokogiri"

module Phlexing
  class Converter
    include Helpers

    attr_accessor :html

    def initialize(html)
      @html = html
      @buffer = StringIO.new
      handle_node
    end

    def handle_text(node, level, newline = true)
      text = node.text.strip

      if text.length.positive?
        @buffer << indent(level)

        if node.parent.children.length > 1
          @buffer << "text "
        end

        @buffer << double_quote(text)
        @buffer << "\n" if newline
      end
    end

    def handle_erb_element(node, level, newline = true)
      if erb_safe_output?(node)
        @buffer << "raw "
        @buffer << node.text.from(1)
        @buffer << "\n" if newline
        return
      end

      if erb_interpolation?(node) && node.parent.children.count > 1
        @buffer << "text "
      elsif erb_comment?(node)
        @buffer << "#"
      end

      @buffer << node.text
      @buffer << "\n" if newline
    end

    def handle_element(node, level)
      @buffer << indent(level) + node.name.gsub("-", "_") + handle_attributes(node)

      if node.children.any?
        if node.children.one? && text_node?(node.children.first) && node.text.length <= 32
          single_line_block {
            handle_text(node.children.first, 0, false)
          }
        elsif node.children.one? && erb_interpolation?(node.children.first) && node.text.length <= 32
          single_line_block {
            handle_erb_element(node.children.first, 0, false)
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

    def handle_children(node, level)
      node.children.each do |child|
        handle_node(child, level + 1)
      end
    end

    def handle_attributes(node)
      return "" if node.attributes.keys.none?

      b = StringIO.new

      node.attributes.values.each do |attribute|
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
      else
        @buffer << "UNKNOWN" + node.class.to_s
      end

      @buffer.string
    end

    def parsed
      @parsed ||= Nokogiri::HTML.fragment(converted_erb)
    end

    def buffer
      Rufo::Formatter.format(@buffer.string.strip)
    rescue Rufo::SyntaxError
      @buffer.string.strip
    end

    def converted_erb
      ErbParser.transform_xml(html)
    rescue
      html
    end
  end
end

require "nokogiri"

module Phlexing
  class Converter
    attr_accessor :html, :buffer

    def initialize(html)
      @html = html
      @buffer = ""
      handle_node
    end

    def indent(level)
      "  " * level
    end

    def double_quote(string)
      "\"#{string}\""
    end

    def single_quote(string)
      "'#{string}'"
    end

    def handle_text(node, level, newline = true)
      text = node.text.strip

      if text.length.positive?
        @buffer << indent(level)

        if node.parent.children.length > 1
          @buffer << "text "
        end

        if text.starts_with?("<%=") && text.ends_with?("%>")
          @buffer << text.from(3).to(-3).strip
        else
          @buffer << double_quote(text)
        end

        @buffer << "\n" if newline
      end
    end

    def do_block_start
      " do\n"
    end

    def do_block_end(level = 0)
      indent(level) + "end\n"
    end

    def handle_element(node, level)
      @buffer << indent(level) + node.name + handle_attributes(node)

      if node.children.any?
        if node.children.one? && node.children.first.is_a?(Nokogiri::XML::Text)
          @buffer << " { "
          handle_text(node.children.first, 0, false)
          @buffer << " }\n"
        else
          @buffer << do_block_start
          handle_children(node, level)
          @buffer << do_block_end(level)
        end
      end
    end

    def handle_children(node, level)
      node.children.each do |child|
        handle_node(child, level + 1)
      end
    end

    def handle_attributes(node)
      return "" if node.attributes.keys.none?

      b = ""

      node.attributes.values.each do |attribute|
        b << attribute.name.gsub("-", "_")
        b << ": "
        b << double_quote(attribute.value)
        b << ", " if node.attributes.values.last != attribute
      end

      if node.children.any?
        "(#{b.strip}) "
      else
        " #{b.strip}"
      end
    end

    def handle_node(node = parsed, level = 0)
      case node
      when Nokogiri::XML::Text
        handle_text(node, level)
      when Nokogiri::XML::Element
        handle_element(node, level)
        @buffer << "\n" if level == 1
      when Nokogiri::HTML4::DocumentFragment
        handle_children(node, level)
      else
        @buffer << "UNKOWN" + node.class.to_s
      end

      @buffer
    end

    def parsed
      @parsed ||= Nokogiri::HTML.fragment(html)
    end
  end
end

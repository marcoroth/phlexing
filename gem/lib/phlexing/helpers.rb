# frozen_string_literal: true

module Phlexing
  module Helpers
    def indent(level)
      return "" if level == 1

      "  " * level
    end

    def double_quote(string)
      "\"#{string}\""
    end

    def single_quote(string)
      "'#{string}'"
    end

    def percent_literal_string(string)
      "%(#{string})"
    end

    def quote(string)
      return double_quote(string) unless string.include?('"')
      return single_quote(string) unless string.include?("'")

      percent_literal_string(string)
    end

    def node_name(node)
      return "template_tag" if node.name == "template"
      return node.name unless node.name.include?("-")

      name = node.name.gsub("-", "_")
      @custom_elements << name

      name
    end

    def do_block_start
      " do\n"
    end

    def do_block_end(level = 0)
      "#{indent(level)}end\n"
    end

    def multi_line_block(level)
      @buffer << " do\n"
      yield
      @buffer << ("#{indent(level)}end\n")
    end

    def single_line_block
      @buffer << " { "
      yield
      @buffer << " }\n"
    end

    def erb_node?(node)
      node.is_a?(Nokogiri::XML::Element) && node.name == "erb"
    end

    def element_node?(node)
      node.is_a?(Nokogiri::XML::Element)
    end

    def text_node?(node)
      node.is_a?(Nokogiri::XML::Text)
    end

    def multiple_children?(node)
      node.children.length > 1
    end

    def siblings?(node)
      multiple_children?(node.parent)
    end

    def erb_interpolation?(node)
      first = node.children.first

      erb_node?(node) &&
        node.children.one? &&
        first.children.none? &&
        text_node?(first) &&
        node.attributes["interpolated"]
    end

    def erb_safe_output?(node)
      erb_interpolation?(node) && node.text.start_with?("=")
    end

    def erb_comment?(node)
      node.attributes["comment"]
    end
  end
end

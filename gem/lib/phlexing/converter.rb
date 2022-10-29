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

    attr_accessor :html, :custom_elements

    def initialize(html)
      @html = html
      @buffer = StringIO.new
      @custom_elements = Set.new
      handle_node
    end

    def handle_text(node, level, newline: true)
      text = node.text

      if text.squish.empty? && text.length.positive?
        @buffer << indent(level)
        @buffer << "whitespace\n"

        text.strip!
      end

      if text.length.positive?
        @buffer << indent(level)

        if siblings?(node)
          @buffer << "text "
        end

        @buffer << double_quote(text)
        @buffer << "\n" if newline
      end
    end

    def handle_erb_element(node, level, newline: true)
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
      @buffer << double_quote(node.text.strip)
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

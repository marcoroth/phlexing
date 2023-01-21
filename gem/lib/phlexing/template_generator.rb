# frozen_string_literal: true

require "nokogiri"

module Phlexing
  class TemplateGenerator
    using Refinements::StringRefinements

    include Helpers

    attr_accessor :converter, :out, :options

    def self.generate(converter, source)
      new(converter).generate(source)
    end

    def initialize(converter)
      @converter = converter
      @options = @converter.options
      @out = StringIO.new
    end

    def generate(source)
      document = Parser.parse(source)
      handle_node(document)

      Formatter.format(out.string.strip)
    end

    def handle_text_node(node)
      text = node.text

      if text.squish.empty? && text.length.positive?
        out << whitespace

        text.strip!
      end

      return if text.length.zero?

      if siblings?(node)
        handle_text_output(quote(node.text))
      else
        output("", quote(text))
      end
    end

    def handle_erb_comment_output(text)
      output("#", text)
    end

    def handle_html_comment_output(text)
      output("comment", quote(text))
    end

    def handle_text_output(text)
      output("text", text)
    end

    def handle_output(text)
      output("", unescape(text).strip)
    end

    def handle_erb_unsafe_output(text)
      output("unsafe_raw", text)
    end

    def handle_erb_safe_node(node)
      if multiple_children?(node.parent) && string_output?(node)
        handle_text_output(node.text.strip)
      else
        handle_output(node.text.strip)
      end
    end

    def handle_tag(node, level)
      out << tag_name(node)
      out << handle_attributes(node)

      if node.children.any?
        block { handle_children(node, level) }
      end

      out << newline
    end

    def handle_children(node, level)
      node.children.each do |child|
        handle_node(child, level + 1)
      end
    end

    def handle_attributes(node)
      return "" if node.attributes.keys.none?

      attributes = []

      node.attributes.each_value do |attribute|
        attributes << String.new.tap { |s|
          s << arg(attribute.name.underscore)
          s << quote(attribute.value)
        }
      end

      parens(attributes.join(", "))
    end

    def handle_loud_erb_node(node)
      if node.text.start_with?("=")
        handle_erb_unsafe_output(node.text.from(1).strip)
      else
        handle_erb_safe_node(node)
      end
    end

    def handle_silent_erb_node(node)
      if node.text.start_with?("#")
        handle_erb_comment_output(node.text.from(1).strip)
      elsif node.text.start_with?("-")
        handle_output(node.text.from(1).to(-2).strip)
      else
        handle_output(node.text.strip)
      end
    end

    def handle_html_comment_node(node)
      handle_html_comment_output(node.text.strip)
    end

    def handle_element_node(node, level)
      case node
      in name: "erb", attributes: [{ name: "loud", value: "" }]
        handle_loud_erb_node(node)
      in name: "erb", attributes: [{ name: "silent", value: "" }]
        handle_silent_erb_node(node)
      in name: "erb"
        handle_output(node.text.strip)
      else
        handle_tag(node, level)
      end

      out << newline if level == 1
    end

    def handle_document_node(node, level)
      handle_children(node, level)
    end

    def handle_node(node, level = 0)
      case node
      in Nokogiri::XML::Text
        handle_text_node(node)
      in Nokogiri::XML::Element
        handle_element_node(node, level)
      in Nokogiri::HTML4::Document | Nokogiri::HTML4::DocumentFragment | Nokogiri::XML::DTD
        handle_document_node(node, level)
      in Nokogiri::XML::Comment
        handle_html_comment_node(node)
      end
    end
  end
end

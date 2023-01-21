# frozen_string_literal: true

require "nokogiri"

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

    def handle_text(node, level)
      text = node.text

      if text.squish.empty? && text.length.positive?
        out << whitespace

        text.strip!
      end

      return if text.length.zero?

      if siblings?(node)
        output("text", quote(text))
      else
        output("", quote(text))
      end
    end

    def handle_comment_output(node)
      output("#", node.text)
    end

    def handle_comment_node(node, level)
      output("comment", quote(node.text))
    end

    def handle_output(node)
      output("", node.text)
    end

    def handle_erb_interpolation(node)
      if node.text.strip.start_with?("=")
        output("unsafe_raw", node.text.from(1))
      elsif multiple_children?(node.parent) && !node.text.strip.start_with?("render")
        output("text", node.text)
      else
        handle_output(node)
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

    def handle_element(node, level)
      case node
      in name: "erb", attributes: [{ name: "interpolated", value: "true" }]
        handle_erb_interpolation(node)
      in name: "erb", attributes: [{ name: "comment", value: "true" }]
        handle_comment_output(node)
      in name: "erb"
        handle_output(node)
      else
        handle_tag(node, level)
      end

      out << newline if level == 1
    end

    def handle_document(node, level)
      handle_children(node, level)
    end

    def handle_node(node, level = 0)
      case node
      in Nokogiri::XML::Text
        handle_text(node, level)
      in Nokogiri::XML::Element
        handle_element(node, level)
      in Nokogiri::HTML4::DocumentFragment
        handle_document(node, level)
      in Nokogiri::XML::Comment
        handle_comment_node(node, level)
      end
    end
  end
end

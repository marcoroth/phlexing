# frozen_string_literal: true

require "phlex"

module Phlexing
  module Helpers
    KNOWN_ELEMENTS = Phlex::HTML::VOID_ELEMENTS.values + Phlex::HTML::STANDARD_ELEMENTS.values

    def whitespace
      options.whitespace? ? "whitespace\n" : ""
    end

    def newline
      "\n"
    end

    def symbol(string)
      ":#{string}"
    end

    def arg(string)
      "#{string}: "
    end

    def quote(string)
      "%(#{string})"
    end

    def parens(string)
      "(#{string})"
    end

    def unescape(html)
      CGI.unescapeHTML(html)
    end

    def tag_name(node)
      return "template_tag" if node.name == "template-tag"

      name = node.name.tr("-", "_")

      @converter.custom_elements << name unless KNOWN_ELEMENTS.include?(name)

      name
    end

    def block
      out << " {"
      yield
      out << " }"
    end

    def output(name, string)
      out << name
      out << " "
      out << string.strip
      out << newline
    end

    def multiple_children?(node)
      node.children.length > 1
    end

    def siblings?(node)
      multiple_children?(node.parent)
    end
  end
end

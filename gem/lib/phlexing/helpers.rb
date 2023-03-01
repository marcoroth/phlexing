# frozen_string_literal: true

require "phlex"
require "phlex-rails"

module Phlexing
  module Helpers
    KNOWN_ELEMENTS = Phlex::HTML::VoidElements::REGISTERED_ELEMENTS.values + Phlex::HTML::StandardElements::REGISTERED_ELEMENTS.values

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

    def braces(string)
      "{ #{string} }"
    end

    def interpolate(string)
      "\#\{#{string}\}"
    end

    def unescape(source)
      CGI.unescapeHTML(source)
    end

    def unwrap_erb(source)
      source
        .delete_prefix("<%==")
        .delete_prefix("<%=")
        .delete_prefix("<%-")
        .delete_prefix("<%#")
        .delete_prefix("<% #")
        .delete_prefix("<%")
        .delete_suffix("-%>")
        .delete_suffix("%>")
        .strip
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

    def blocklist
      [
        "render",
        "tag",
        "form_with",
        "link_to",
        "t",
        "translate"
      ]
    end

    def regex_filter
      [
        /\w+_field/,
        /\w+_tag/,
        /\w+_select/,
        /\w+_for/,
        /select_\w+/
      ]
    end

    def string_output?(node)
      word = node.text.strip.scan(/^\w+/)[0]

      return true if word.nil?

      blocklist_matched = blocklist.include?(word)
      filter_matched = regex_filter.map { |regex| word.scan(regex).any? }.reduce(:|)

      !(blocklist_matched || filter_matched)
    end

    def children?(node)
      node.children.length >= 1
    end

    def multiple_children?(node)
      node.children.length > 1
    end

    def siblings?(node)
      multiple_children?(node.parent)
    end
  end
end

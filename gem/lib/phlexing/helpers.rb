# frozen_string_literal: true

require "phlex"
require "phlex-rails"

module Phlexing
  module Helpers
    KNOWN_ELEMENTS =
      Phlex::HTML::VoidElements.registered_elements.values +
      Phlex::HTML::StandardElements.registered_elements.values

    SVG_ELEMENTS = Phlex::SVG::StandardElements.registered_elements.values.to_h { |element| [element.downcase, element] }

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
      if string.include?(".")
        %("#{string}": )
      else
        "#{string}: "
      end
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
      name = node.name.tr("-", "_")

      return name if name == "template_tag"
      return name if name.start_with?("s.")
      return name if KNOWN_ELEMENTS.include?(name)

      @converter.custom_elements << name

      name
    end

    def block(params = nil)
      out << " {"

      if params
        out << " "
        out << "|"
        out << params
        out << "|"
      end

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
        "render"
      ]
    end

    def routes_helpers
      [
        /\w+_url/,
        /\w+_path/
      ]
    end

    def known_rails_helpers
      Phlex::Rails::Helpers
        .constants
        .reject { |m| m == :Routes }
        .map { |m| Module.const_get("::Phlex::Rails::Helpers::#{m}") }
        .each_with_object({}) { |m, sum|
          (m.instance_methods - Module.instance_methods).each do |method|
            sum[method.to_s] = m.name
          end
        }
    end

    def string_output?(node)
      word = node.text.strip.scan(/^\w+/)[0]

      return true if word.nil?

      blocklist_matched = known_rails_helpers.keys.include?(word) || blocklist.include?(word)
      route_matched = routes_helpers.map { |regex| word.scan(regex).any? }.reduce(:|)

      !(blocklist_matched || route_matched)
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

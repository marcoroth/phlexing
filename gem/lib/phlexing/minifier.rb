# frozen_string_literal: true

require "html_press"

module Phlexing
  class Minifier
    def self.minify(source)
      minified = HtmlPress.press(source.to_s)
      minified = minify_html_entities(minified)

      minified
    rescue StandardError
      source
    end

    def self.minify_html_entities(source)
      source
        .gsub("& lt;", "&lt;")
        .gsub("& quot;", "&quot;")
        .gsub("& gt;", "&gt;")
        .gsub("& #amp;", "&#amp;")
        .gsub("& #38;", "&#38;")
        .gsub("& #60;", "&#60;")
        .gsub("& #62;", "&#62;")
    end
  end
end

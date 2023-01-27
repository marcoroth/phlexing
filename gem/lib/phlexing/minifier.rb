# frozen_string_literal: true

require "html_press"

module Phlexing
  class Minifier
    def self.call(...)
      new(...).call
    end

    def initialize(source)
      @source = source.to_s.dup
    end

    def call
      minify
      minify_html_entities

      @source
    end

    private

    def minify
      @source = HtmlPress.press(@source)
    rescue StandardError
      @source
    end

    def minify_html_entities
      @source = @source
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

# frozen_string_literal: true

require "html_press"

module Phlexing
  class Minifier
    def self.minify(source)
      HtmlPress.press(source.to_s)
    rescue StandardError
      source
    end
  end
end

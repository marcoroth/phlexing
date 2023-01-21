# frozen_string_literal: true

require "html_press"

module Phlexing
  class Minifier
    def self.minify(source)
      pressed = HtmlPress.press(source.to_s)
      pressed = press_more(pressed)

      pressed
    rescue StandardError
      source
    end

    def self.press_more(source)
      source.gsub(" <erb", "<erb")
    end
  end
end

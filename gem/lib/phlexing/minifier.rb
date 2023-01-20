# frozen_string_literal: true

require "html_press"

module Phlexing
  class Minifier
    def self.minify(html)
      HtmlPress.press(html)
    rescue StandardError
      html
    end
  end
end

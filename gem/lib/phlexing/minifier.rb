# frozen_string_literal: true

require "html_press"

module Phlexing
  class Minifier
    def self.minify(html)
      puts html
      puts "---"
      x = HtmlPress.press(html.to_s)
      puts x
      x
    rescue StandardError
      html
    end
  end
end

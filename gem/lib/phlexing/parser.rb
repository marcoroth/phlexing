# frozen_string_literal: true

require "nokogiri"

module Phlexing
  class Parser
    def self.parse(html)
      transformed_erb = ErbTransformer.transform(html.to_s)
      minified_erb = Minifier.minify(transformed_erb)

      parsed = Nokogiri::HTML5.parse(minified_erb)

      if html.include?("<html")
        parsed
      else
        parsed.css("body")[0]
      end
    end
  end
end

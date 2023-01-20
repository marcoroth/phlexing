# frozen_string_literal: true

require "nokogiri"

module Phlexing
  class Parser
    def self.parse(html)
      transformed_erb = ErbTransformer.transform(html)
      minified_erb = Minifier.minify(transformed_erb)

      Nokogiri::HTML.fragment(minified_erb)
    end
  end
end

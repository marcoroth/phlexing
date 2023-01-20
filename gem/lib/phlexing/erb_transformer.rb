# frozen_string_literal: true

require "erb_parser"

module Phlexing
  class ErbTransformer
    def self.transform(html)
      ErbParser.transform_xml(html).gsub("\n", "").gsub("\r", "")
    rescue StandardError
      html
    end
  end
end

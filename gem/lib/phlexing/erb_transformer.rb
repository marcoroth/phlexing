# frozen_string_literal: true

require "erb_parser"

module Phlexing
  class ErbTransformer
    def self.transform(html)
      ErbParser.transform_xml(html).tr("\n", "").tr("\r", "")
    rescue StandardError
      html
    end
  end
end

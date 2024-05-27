# frozen_string_literal: true

require "nokogiri"
require "nokogiri/html5/inference"

module Phlexing
  class Parser
    def self.call(source)
      source = ERBTransformer.call(source)
      source = Minifier.call(source)

      Nokogiri::HTML5::Inference.parse(source)
    end
  end
end

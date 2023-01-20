# frozen_string_literal: true

require "nokogiri"

module Phlexing
  class Converter
    attr_accessor :html, :custom_elements, :options, :analyzer

    def self.convert(html, **options)
      new(**options).convert(html)
    end

    def convert(html)
      @html = html
      analyzer.analyze(html)

      code
    end

    def initialize(html = nil, **options)
      @custom_elements = Set.new
      @analyzer = RubyAnalyzer.new
      @options = Options.new(**options)

      convert(html)
    end

    def code
      options.component? ? component_code : template_code
    end

    def template_code
      TemplateGenerator.generate(self, html)
    end

    def component_code
      ComponentGenerator.generate(self)
    end
  end
end

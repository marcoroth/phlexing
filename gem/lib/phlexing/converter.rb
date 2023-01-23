# frozen_string_literal: true

module Phlexing
  class Converter
    attr_accessor :source, :custom_elements, :options, :analyzer

    def self.convert(source, **options)
      new(**options).convert(source)
    end

    def convert(source)
      @source = source
      analyzer.analyze(source)

      code
    end

    def initialize(source = nil, **options)
      @custom_elements = Set.new
      @analyzer = RubyAnalyzer.new
      @options = Options.new(**options)

      convert(source)
    end

    def code
      options.component? ? component_code : template_code
    end

    # private

    def template_code
      TemplateGenerator.generate(self, source)
    end

    def component_code
      ComponentGenerator.generate(self)
    end
  end
end

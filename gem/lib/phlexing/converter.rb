# frozen_string_literal: true

module Phlexing
  class Converter
    attr_accessor :source, :custom_elements, :options

    def self.call(source, **options)
      new(**options).call(source)
    end

    def self.convert(source, **options)
      new(**options).call(source)
    end

    def call(source)
      @source = source

      code
    end

    def initialize(source = nil, **options)
      @custom_elements = Set.new
      @options = Options.new(**options)

      call(source)
    end

    def code
      options.component? ? component_code : template_code
    end

    # private

    def template_code
      TemplateGenerator.generate(self, source)
    end

    def component_code
      ComponentGenerator.call(self)
    end
  end
end

# frozen_string_literal: true

require "slim/erb_converter"

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

      source_converted = options[:templating_lang] == :slim ? convert_slim_to_erb(source) : source
      # binding.pry if @options[:templating_lang] == :slim
      call(source_converted)
    end

    def code
      options.component? ? component_code : template_code
    end

    # private

    def convert_slim_to_erb(source) = slim_converter.call(source)

    def slim_converter = Slim::ERBConverter.new

    def template_code
      TemplateGenerator.call(self, source)
    end

    def component_code
      ComponentGenerator.call(self)
    end
  end
end

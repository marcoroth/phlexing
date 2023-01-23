# frozen_string_literal: true

module Phlexing
  class ComponentGenerator
    include Helpers

    attr_accessor :converter

    def self.generate(converter)
      new(converter).generate
    end

    def initialize(converter)
      @converter = converter
    end

    def generate
      out = StringIO.new

      out << "class "
      out << options.component_name
      out << " < "
      out << options.parent_component
      out << newline

      if analyzer.locals.any?
        out << "attr_accessor "
        out << build_accessors
        out << newline
        out << newline
      end

      converter.custom_elements.sort.each do |element|
        out << "register_element :"
        out << element
        out << newline
      end

      out << newline if converter.custom_elements.any?

      if kwargs.any?
        out << "def initialize("
        out << build_kwargs
        out << ")"
        out << newline

        kwargs.each do |dep|
          out << "@#{dep} = #{dep}\n"
        end

        out << "end"
        out << newline
        out << newline
      end

      out << "def template"
      out << newline
      out << converter.template_code
      out << newline
      out << "end"
      out << newline
      out << "end"
      out << newline

      Formatter.format(out.string.strip)
    rescue StandardError
      out.string.strip
    end

    private

    def kwargs
      Set.new(analyzer.ivars + analyzer.locals).sort
    end

    def build_kwargs
      kwargs.map { |kwarg| arg(kwarg) }.join(", ")
    end

    def build_accessors
      analyzer.locals.sort.map { |local| symbol(local) }.join(", ")
    end

    def analyzer
      converter.analyzer
    end

    def options
      converter.options
    end
  end
end

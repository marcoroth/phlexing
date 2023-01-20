# frozen_string_literal: true

require "rufo"

module Phlexing
  class OutputGenerator
    using Refinements::StringRefinements

    include Helpers

    attr_accessor :converter

    def initialize(converter)
      @converter = converter
    end

    def generate
      out = StringIO.new

      if should_generate_class?
        out << "class #{component_name} "
        out << "< #{parent_component}\n"

        if converter.locals.any?
          out << indent(1)
          out << "attr_accessor "
          out << converter.locals.sort.map { |local| ":#{local}" }.join(", ")
          out << "\n\n"
        end

        converter.custom_elements.sort.each do |element|
          out << indent(1)
          out << "register_element :#{element}\n"
        end

        if kwargs.any?
          out << indent(1)
          out << "def initialize("
          out << kwargs.map { |kwarg| "#{kwarg}: " }.join(", ")
          out << ")\n"

          kwargs.each do |dep|
            out << indent(2)
            out << "@#{dep} = #{dep}\n"
          end

          out << indent(1)
          out << "end\n"
        end

        out << indent(1)
        out << "def template\n"

        out << indent(2)
        out << converter.buffer

        out << indent(1)
        out << "end\n"
        out << "end\n"
      else
        out << converter.buffer
      end

      Rufo::Formatter.format(out.string.strip)
    rescue Rufo::SyntaxError
      out.string.strip
    end

    private

    def should_generate_class?
      converter.options.fetch(:phlex_class, false)
    end

    def kwargs
      Set.new(converter.ivars + converter.locals).sort
    end

    def component_name
      safe_constant_name(converter.options.fetch(:component_name, "Component"))
    end

    def parent_component
      safe_constant_name(converter.options.fetch(:parent_component, "Phlex::HTML"))
    end
  end
end

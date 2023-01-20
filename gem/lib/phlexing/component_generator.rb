# frozen_string_literal: true

module Phlexing
  class ComponentGenerator
    using Refinements::StringRefinements

    include Helpers

    attr_accessor :converter

    def initialize(converter)
      @converter = converter
    end

    def generate
      out = StringIO.new

      out << "class #{options.component_name} "
      out << "< #{options.parent_component}\n"

      if analyzer.locals.any?
        out << indent(1)
        out << "attr_accessor "
        out << analyzer.locals.sort.map { |local| ":#{local}" }.join(", ")
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
      out << converter.template_code
      out << "\n"

      out << indent(1)
      out << "end\n"
      out << "end\n"

      Formatter.format(out.string.strip)
    end

    private

    def kwargs
      Set.new(analyzer.ivars + analyzer.locals).sort
    end

    def analyzer
      converter.analyzer
    end

    def options
      converter.options
    end
  end
end

# frozen_string_literal: true

module Phlexing
  class NameSuggestor
    def self.suggest(html)
      converter = Phlexing::Converter.new(html)

      suggest_raw_name(converter).camelize
    end

    def self.suggest_raw_name(converter)
      # if there is just one ivar or locals we use that
      # since that argument makes the component unique enough
      if converter.ivars.one?
        return "#{converter.ivars.first}_component"
      end

      if converter.locals.one?
        return "#{converter.locals.first}_component"
      end

      if converter.parsed
        elements = converter.parsed.children.map { |element| extract_name_from_element(element) }.compact

        return elements.first if elements.any?
      end

      if converter.ivars.any?
        return "#{converter.ivars.first}_component"
      end

      if converter.locals.any?
        return "#{converter.locals.first}_component"
      end

      "Component"
    end

    def self.extract_name_from_element(element)
      if element
        if (id = element.attributes.try(:[], "id")) && !id.value.include?("<erb")
          return "#{id.value.strip.gsub('-', '_')}_component"
        end

        if (classes = element.attributes.try(:[], "class"))
          classes = classes.value.split
          return "#{classes[0].strip.gsub('-', '_')}_component"
        end

        return "#{element.name}_component" unless ["div", "span", "p", "erb"].include?(element.name)
      end
    end
  end
end

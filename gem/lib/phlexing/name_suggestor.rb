# frozen_string_literal: true

module Phlexing
  class NameSuggestor
    using Refinements::StringRefinements

    def self.call(source)
      document = Parser.call(source)
      analyzer = RubyAnalyzer.call(source)

      ivars  = analyzer.ivars
      locals = analyzer.locals

      ids     = extract(document, :extract_id_from_element)
      classes = extract(document, :extract_class_from_element)
      tags    = extract(document, :extract_tag_name_from_element)

      return wrap(ivars.first) if ivars.one? && locals.none?
      return wrap(locals.first) if locals.one? && ivars.none?
      return wrap(ids.first) if ids.any?
      return wrap(ivars.first) if ivars.any?
      return wrap(locals.first) if locals.any?
      return wrap(classes.first) if classes.any?
      return wrap(tags.first) if tags.any?

      "Component"
    end

    def self.wrap(name)
      "#{name}_component".underscore.camelize
    end

    def self.extract(document, method)
      return [] unless document

      document.map { |element| send(method, element) }.compact
    end

    def self.extract_id_from_element(element)
      return if element.nil?
      return if element.is_a?(Nokogiri::XML::Text)

      id_attribute = element.attributes && element.attributes["id"]
      return if id_attribute.nil?

      id = id_attribute.value.to_s.strip
      return if id.include?("<erb")

      id
    end

    def self.extract_class_from_element(element)
      return if element.nil?
      return if element.is_a?(Nokogiri::XML::Text)

      class_attribute = element.attributes && element.attributes["class"]

      return if class_attribute.nil?

      classes = class_attribute.value.strip.split

      return if classes.empty?

      classes[0]
    end

    def self.extract_tag_name_from_element(element)
      return if element.nil?
      return if element.is_a?(Nokogiri::XML::Text)

      return if ["div", "span", "p", "erb"].include?(element.name)

      element.name
    end
  end
end

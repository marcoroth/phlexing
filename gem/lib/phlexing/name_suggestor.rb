# frozen_string_literal: true

module Phlexing
  class NameSuggestor
    using Refinements::StringRefinements

    def self.suggest(html)
      converter = Phlexing::Converter.new(html)

      ivars  = converter.ivars
      locals = converter.locals

      ids     = extract(converter, :extract_id_from_element)
      classes = extract(converter, :extract_class_from_element)
      tags    = extract(converter, :extract_tag_name_from_element)

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
      "#{name}_component".gsub("-", "_").gsub(" ", "_").camelize
    end

    def self.extract(converter, method)
      return [] unless converter.parsed

      converter.parsed.children.map { |element| send(method, element) }.compact
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

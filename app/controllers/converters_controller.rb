# frozen_string_literal: true

class ConvertersController < ApplicationController
  def index
  end

  def create
    source = params["input"] || ""
    whitespace = params["whitespace"] ? true : false
    component = params["component"] ? true : false

    component_name = params["component_name"].presence || Phlexing::NameSuggestor.call(source)
    component_name = component_name.gsub(" ", "_").camelize

    parent_component = params["parent_component"].presence || "Phlex::HTML"
    parent_component = parent_component.gsub(" ", "_").camelize

    @converter = Phlexing::Converter.new(
      source,
      whitespace: whitespace,
      component: component,
      component_name: component_name,
      parent_component: parent_component
    )
  end
end

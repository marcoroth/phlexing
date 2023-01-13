# frozen_string_literal: true

class ConvertersController < ApplicationController
  def index
  end

  def create
    content = params["input"] || ""
    whitespace = params["whitespace"] ? true : false
    phlex_class = params["phlex_class"] ? true : false

    component_name = params["component_name"].presence || Phlexing::Converter.suggest_name(content)
    component_name = component_name.gsub(" ", "_").camelize

    parent_component = params["parent_component"].presence || "Phlex::HTML"
    parent_component = parent_component.gsub(" ", "_").camelize

    @converter = Phlexing::Converter.new(
      content,
      whitespace: whitespace,
      phlex_class: phlex_class,
      component_name: component_name,
      parent_component: parent_component
    )
  end
end

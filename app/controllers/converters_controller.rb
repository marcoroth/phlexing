# frozen_string_literal: true

class ConvertersController < ApplicationController
  def index
  end

  def create
    source = params["input"] || ""
    whitespace = params["whitespace"] ? true : false
    component = params["component"] ? true : false

    component_name = params["component_name"].presence || Phlexing::NameSuggestor.suggest(source)
    component_name = component_name.gsub(" ", "_").camelize

    parent_component = params["parent_component"].presence || "Phlex::HTML"
    parent_component = parent_component.gsub(" ", "_").camelize

    converter = Phlexing::Converter.new(
      source,
      whitespace: whitespace,
      component: component,
      component_name: component_name,
      parent_component: parent_component
    )

    @code = converter.code
  end

  def update
    code = params["code"]

    if code && false
      client = OpenAI::Client.new

      response = client.edits(
        parameters: {
          model: "text-davinci-edit-001",
          instruction: "Extract private methods from this Ruby code",
          input: code
        }
      )

      @code = response.dig("choices", 0, "text") || ""

      if (error = response.dig("error", "message"))
        @code = "# #{error}"
      end
    else
      @code = "# Refactored #{Time.now} \n\n#{code}"
    end
  end
end

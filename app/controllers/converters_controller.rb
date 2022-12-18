# frozen_string_literal: true

class ConvertersController < ApplicationController
  def index
  end

  def create
    content = params["input"] || ""

    @parser = Phlexing::Converter.new(content)

    # sleep 2

    @phlex_output = Phlexing::Renderer::Phlex.render(@parser)
    @erb_output = Phlexing::Renderer::Erb.render(content)
  end
end

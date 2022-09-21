# frozen_string_literal: true

class ConvertersController < ApplicationController
  def index
  end

  def create
    content = params["input"] || ""

    @parser = Phlexing::Converter.new(content)
  end
end

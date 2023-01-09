# frozen_string_literal: true

class ConvertersController < ApplicationController
  def index
  end

  def create
    content = params["input"] || ""
    whitespace = params["whitespace"] ? true : false

    @parser = Phlexing::Converter.new(content, whitespace: whitespace)
  end
end

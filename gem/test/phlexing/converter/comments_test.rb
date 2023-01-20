# frozen_string_literal: true

require_relative "../../test_helper"

class Phlexing::Converter::CommentsTest < Minitest::Spec
  # it "HTML comment" do
  #   html = <<~HTML.strip
  #     <!-- Hello World -->
  #     <div>Hello World</div>
  #   HTML
  #
  #   expected = <<~PHLEX.strip
  #     comment "Hello World"
  #     div { "Hello World" }
  #   PHLEX
  #
  #   assert_phlex expected, html
  # end

  # it "HTML comment with double quotes" do
  #   html = <<~HTML.strip
  #     <!-- Hello "World" -->
  #     <div>Hello World</div>
  #   HTML
  #
  #   expected = <<~PHLEX.strip
  #     comment 'Hello "World"'
  #     div { "Hello World" }
  #   PHLEX
  #
  #   assert_phlex expected, html
  # end
end

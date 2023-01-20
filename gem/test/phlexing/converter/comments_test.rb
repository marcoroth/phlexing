# frozen_string_literal: true

require_relative "../../test_helper"

class Phlexing::Converter::CommentsTest < Minitest::Spec
  it "HTML comment" do
    expected = <<~HTML.strip
      comment "Hello World"
      div { "Hello World" }
    HTML

    html = <<~HTML.strip
      <!-- Hello World -->
      <div>Hello World</div>
    HTML

    assert_phlex expected, html
  end

  it "HTML comment with double quotes" do
    expected = <<~HTML.strip
      comment 'Hello "World"'
      div { "Hello World" }
    HTML

    html = <<~HTML.strip
      <!-- Hello "World" -->
      <div>Hello World</div>
    HTML

    assert_phlex expected, html
  end
end

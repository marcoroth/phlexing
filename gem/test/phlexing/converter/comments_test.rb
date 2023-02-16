# frozen_string_literal: true

require_relative "../../test_helper"

class Phlexing::Converter::CommentsTest < Minitest::Spec
  it "HTML comment" do
    html = <<~HTML.strip
      <!-- Hello Comment -->
      <div>Hello World</div>
    HTML

    expected = <<~PHLEX.strip
      comment { "Hello Comment" }
      div { "Hello World" }
    PHLEX

    assert_phlex_template expected, html
  end

  it "HTML comment with single quotes" do
    html = <<~HTML.strip
      <!-- Hello 'Comment' -->
      <div>Hello World</div>
    HTML

    expected = <<~PHLEX.strip
      comment { "Hello 'Comment'" }
      div { "Hello World" }
    PHLEX

    assert_phlex_template expected, html
  end

  it "HTML comment with double quotes" do
    html = <<~HTML.strip
      <!-- Hello "Comment" -->
      <div>Hello World</div>
    HTML

    expected = <<~PHLEX.strip
      comment { %(Hello "Comment") }
      div { "Hello World" }
    PHLEX

    assert_phlex_template expected, html
  end

  it "HTML comment with single and double quotes" do
    html = <<~HTML.strip
      <!-- Hello 'Comment" -->
      <div>Hello World</div>
    HTML

    expected = <<~PHLEX.strip
      comment { %(Hello 'Comment") }
      div { "Hello World" }
    PHLEX

    assert_phlex_template expected, html
  end
end

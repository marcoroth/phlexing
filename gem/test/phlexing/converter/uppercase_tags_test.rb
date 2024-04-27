# frozen_string_literal: true

require_relative "../../test_helper"

class Phlexing::Converter::UppercaseTagsTest < Minitest::Spec
  it "basic uppercase tags" do
    assert_phlex_template "div", %(<DIV></DIV>)
    assert_phlex_template "span", %(<SPAN></SPAN>)
    assert_phlex_template "p", %(<P></P>)
    assert_phlex_template "template_tag", %(<TEMPLATE></TEMPLATE>)
    assert_phlex_template "html", %(<HTML></HTML>)
    assert_phlex_template "head", %(<HEAD></HEAD>)
    assert_phlex_template "body", %(<BODY></BODY>)
  end

  it "standlone uppercase body tag" do
    html = <<~HTML.strip
      <BODY></BODY>
    HTML

    expected = <<~PHLEX.strip
      body
    PHLEX

    assert_phlex_template expected, html
  end

  it "standlone uppercase head tag" do
    html = <<~HTML.strip
      <HEAD></HEAD>
    HTML

    expected = <<~PHLEX.strip
      head
    PHLEX

    assert_phlex_template expected, html
  end

  it "standlone uppercase html tag" do
    html = <<~HTML.strip
      <HTML></HTML>
    HTML

    expected = <<~PHLEX.strip
      html
    PHLEX

    assert_phlex_template expected, html
  end

  it "standlone uppercase head and body tag" do
    html = <<~HTML.strip
      <HEAD></HEAD>
      <BODY></BODY>
    HTML

    expected = <<~PHLEX.strip
      html do
        head

        body
      end
    PHLEX

    assert_phlex_template expected, html
  end

  it "basic uppercase document" do
    html = <<~HTML.strip
      <HTML>
        <HEAD></HEAD>
        <BODY></BODY>
      </HTML>
    HTML

    expected = <<~PHLEX.strip
      html do
        head
        whitespace
        body
      end
    PHLEX

    assert_phlex_template expected, html
  end
end

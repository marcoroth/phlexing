# frozen_string_literal: true

require_relative "../../test_helper"

class Phlexing::Converter::TagsTest < Minitest::Spec
  it "basic tags" do
    assert_phlex_template "div", %(<div></div>)
    assert_phlex_template "span", %(<span></span>)
    assert_phlex_template "p", %(<p></p>)
    assert_phlex_template "template_tag", %(<template></template>)
    assert_phlex_template "html", %(<html></html>)
    assert_phlex_template "head", %(<head></head>)
    assert_phlex_template "header", %(<header></header>)
    assert_phlex_template "body", %(<body></body>)
  end

  it "basic self closing tag" do
    assert_phlex_template %(img), %(<img />)
    assert_phlex_template %(br), %(<br />)
  end

  it "tag with one attribute" do
    assert_phlex_template %(div(class: "app")), %(<div class="app"></div>)
  end

  it "tag with multiple attributes" do
    assert_phlex_template %(div(class: "app", id: "body")), %(<div class="app" id="body"></div>)
  end

  it "tag with dasherized attributes" do
    assert_phlex_template %(div(custom_class: "app", custom_id: "body")), %(<div custom-class="app" custom-id="body"></div>)
  end

  it "tag with data attributes" do
    assert_phlex_template %(div(data_class: "app", data_id: "body")), %(<div data-class="app" data-id="body"></div>)
  end

  it "tag with attributes and single text node child" do
    assert_phlex_template %{div(class: "app", id: "body") { "Text" }}, %(<div class="app" id="body">Text</div>)
  end

  it "tag with one text node child" do
    assert_phlex_template %(div { "Text" }), %(<div>Text</div>)
  end

  it "tag with one text node child with single quotes" do
    assert_phlex_template %(div { "Text with 'single quotes'" }), %(<div>Text with 'single quotes'</div>)
  end

  it "tag with one text node child with double quotes" do
    assert_phlex_template %(div { %(Text with "double quotes") }), %(<div>Text with "double quotes"</div>)
  end

  it "tag with two children, one text node with double quotes and regular element" do
    html = %(<div>Text with 'single quotes' and "double quotes"<span>Text with "double quotes" and 'single quotes'</span></div>)

    expected = <<~PHLEX.strip
      div do
        plain %(Text with 'single quotes' and "double quotes")
        span { %(Text with "double quotes" and 'single quotes') }
      end
    PHLEX

    assert_phlex_template expected, html
  end

  it "tag with one text node child with single and double quotes" do
    html = %(<div>Text with 'single quotes' and "double quotes"</div>)

    expected = <<~PHLEX.strip
      div { %(Text with 'single quotes' and "double quotes") }
    PHLEX

    assert_phlex_template expected, html
  end

  it "tag with one text node child and long content" do
    html = %(<div>This is a super long text which exceeds the single line block limit and therefore is wrapped in a block</div>)

    expected = <<~PHLEX.strip
      div do
        "This is a super long text which exceeds the single line block limit and therefore is wrapped in a block"
      end
    PHLEX

    assert_phlex_template expected, html
  end

  it "tag with attributes and mulitple children" do
    html = %(<div class="app" id="body"><h1>Title 1</h1><h2>Title 2<span>Small Addition</span></h2></div>)

    expected = <<~PHLEX.strip
      div(class: "app", id: "body") do
        h1 { "Title 1" }
        h2 do
          plain "Title 2"
          span { "Small Addition" }
        end
      end
    PHLEX

    assert_phlex_template expected, html
  end

  it "tag with multiple text and element children" do
    html = %(<div>Text<br />Line 2</div>)

    expected = <<~PHLEX.strip
      div do
        plain "Text"
        br
        plain "Line 2"
      end
    PHLEX

    assert_phlex_template expected, html
  end

  it "tag with one tag node child" do
    html = %(<div><span></span></div>)

    expected = <<~PHLEX.strip
      div { span }
    PHLEX

    assert_phlex_template expected, html
  end

  it "basic html document" do
    html = <<~HTML.strip
      <head></head>
      <body></body>
    HTML

    expected = <<~PHLEX.strip
      html do
        head

        body
      end
    PHLEX

    assert_phlex_template expected, html
  end

  it "standlone head and body tag" do
    html = <<~HTML.strip
      <head></head>
      <body></body>
    HTML

    expected = <<~PHLEX.strip
      html do
        head

        body
      end
    PHLEX

    assert_phlex_template expected, html
  end

  it "standlone head tag" do
    html = <<~HTML.strip
      <head></head>
    HTML

    expected = <<~PHLEX.strip
      head
    PHLEX

    assert_phlex_template expected, html
  end

  it "standlone head tag with attributes" do
    html = <<~HTML.strip
      <head id="123"></head>
    HTML

    expected = <<~PHLEX.strip
      head(id: "123")
    PHLEX

    assert_phlex_template expected, html
  end

  it "standlone body tag" do
    html = <<~HTML.strip
      <body></body>
    HTML

    expected = <<~PHLEX.strip
      body
    PHLEX

    assert_phlex_template expected, html
  end

  it "should convert header tag" do
    html = %(<header>Hello</header>)

    expected = <<~PHLEX.strip
      header { "Hello" }
    PHLEX

    assert_phlex_template expected, html
  end

  it "should convert header tag with attributes" do
    html = %(<header id="123">Hello</header>)

    expected = <<~PHLEX.strip
      header(id: "123") { "Hello" }
    PHLEX

    assert_phlex_template expected, html
  end

  it "should convert boolean attributes properly" do
    html = %(<input required>)

    expected = <<~PHLEX.strip
      input(required: true)
    PHLEX

    assert_phlex_template expected, html
  end

  it "should convert blank attributes properly" do
    html = %(<input required="">)

    expected = <<~PHLEX.strip
      input(required: "")
    PHLEX

    assert_phlex_template expected, html
  end
end

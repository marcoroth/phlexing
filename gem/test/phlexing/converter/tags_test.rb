# frozen_string_literal: true

require_relative "../../test_helper"

class Phlexing::Converter::CustomElementsTest < Minitest::Spec
  it "basic tags" do
    assert_phlex_template "div", %(<div></div>)
    assert_phlex_template "span", %(<span></span>)
    assert_phlex_template "p", %(<p></p>)
    assert_phlex_template "template_tag", %(<template></template>)
  end

  it "basic self closing tag" do
    assert_phlex_template %(img), %(<img />)
    assert_phlex_template %(br), %(<br />)
  end

  it "tag with one attribute" do
    assert_phlex_template %(div class: "app"), %(<div class="app"></div>)
  end

  it "tag with multiple attributes" do
    assert_phlex_template %(div class: "app", id: "body"), %(<div class="app" id="body"></div>)
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
    assert_phlex_template %(div { 'Text with "double quotes"' }), %(<div>Text with "double quotes"</div>)
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
          text "Title 2"
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
        text "Text"
        br
        text "Line 2"
      end
    PHLEX

    assert_phlex_template expected, html
  end

  it "tag with long text gets wrapped into parenthesis" do
    html = %(<div>Text<%= "A super long text which gets wrapped in parenthesis" %></div>)

    expected = <<~PHLEX.strip
      div do
        text "Text"
        text("A super long text which gets wrapped in parenthesis")
      end
    PHLEX

    assert_phlex_template expected, html
  end

  it "tag with long erb interpolation gets wrapped into parenthesis" do
    html = %(<div>Text<%= long_method_name(with: "a bunch", of: :arguments) %></div>)

    expected = <<~PHLEX.strip
      div do
        text "Text"
        text(long_method_name(with: "a bunch", of: :arguments))
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
end

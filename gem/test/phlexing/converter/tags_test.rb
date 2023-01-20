# frozen_string_literal: true

require_relative "../../test_helper"

class Phlexing::Converter::CustomElementsTest < Minitest::Spec
  it "basic tags" do
    assert_phlex "div", %(<div></div>)
    assert_phlex "span", %(<span></span>)
    assert_phlex "p", %(<p></p>)
    assert_phlex "template_tag", %(<template></template>)
  end

  it "basic self closing tag" do
    assert_phlex %(img), %(<img />)
    assert_phlex %(br), %(<br />)
  end

  it "tag with one attribute" do
    assert_phlex %(div class: "app"), %(<div class="app"></div>)
  end

  it "tag with multiple attributes" do
    assert_phlex %(div class: "app", id: "body"), %(<div class="app" id="body"></div>)
  end

  it "tag with attributes and single text node child" do
    assert_phlex %{div(class: "app", id: "body") { "Text" }}, %(<div class="app" id="body">Text</div>)
  end

  it "tag with one text node child" do
    assert_phlex %(div { "Text" }), %(<div>Text</div>)
  end

  it "tag with one text node child with single quotes" do
    assert_phlex %(div { "Text with 'single quotes'" }), %(<div>Text with 'single quotes'</div>)
  end

  it "tag with one text node child with double quotes" do
    assert_phlex %(div { 'Text with "double quotes"' }), %(<div>Text with "double quotes"</div>)
  end

  it "tag with one text node child with single and double quotes" do
    expected = <<~HTML.strip
      div do
        %(Text with 'single quotes' and "double quotes")
      end
    HTML

    assert_phlex expected, %(<div>Text with 'single quotes' and "double quotes"</div>)
  end

  it "tag with one text node child and long content" do
    expected = <<~HTML.strip
      div do
        "This is a super long text which exceeds the single line block limit"
      end
    HTML

    assert_phlex expected, %(<div>This is a super long text which exceeds the single line block limit</div>)
  end

  it "tag with attributes and mulitple children" do
    expected = <<~HTML.strip
      div(class: "app", id: "body") do
        h1 { "Title 1" }
        h2 do
          text "Title 2"
          span { "Small Addition" }
        end
      end
    HTML

    assert_phlex expected, %(<div class="app" id="body"><h1>Title 1</h1><h2>Title 2<span>Small Addition</span></h2></div>)
  end

  it "tag with multiple text and element children" do
    expected = <<~HTML.strip
      div do
        text "Text"
        br
        text "Line 2"
      end
    HTML

    assert_phlex expected, %(<div>Text<br />Line 2</div>)
  end

  it "tag with long text gets wrapped into parenthesis" do
    expected = <<~HTML.strip
      div do
        text "Text"
        text("A super long text which gets wrapped in parenthesis")
      end
    HTML

    assert_phlex expected, %(<div>Text<%= "A super long text which gets wrapped in parenthesis" %></div>)
  end

  it "tag with long erb interpolation gets wrapped into parenthesis" do
    expected = <<~HTML.strip
      div do
        text "Text"
        text(long_method_name(with: "a bunch", of: :arguments))
      end
    HTML

    assert_phlex expected, %(<div>Text<%= long_method_name(with: "a bunch", of: :arguments) %></div>)
  end

  it "tag with one tag node child" do
    expected = <<~HTML.strip
      div do
        span
      end
    HTML

    assert_phlex expected, %(<div><span></span></div>)
  end
end

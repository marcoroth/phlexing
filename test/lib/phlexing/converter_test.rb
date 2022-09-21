# frozen_string_literal: true

require "test_helper"

module Phlexing
  class ConverterTest < ActiveSupport::TestCase
    test "basic tags" do
      assert_equal "div", convert_html(%(<div></div>))
      assert_equal "span", convert_html(%(<span></span>))
      assert_equal "p", convert_html(%(<p></p>))
    end

    test "basic tags with whitespace" do
      assert_equal "div { }", convert_html(%(<div> </div>))
      assert_equal "span { }", convert_html(%(<span> </span>))
      assert_equal "p { }", convert_html(%(<p> </p>))
    end

    test "basic self closing tag" do
      assert_equal %(img), convert_html(%(<img />))
      assert_equal %(br), convert_html(%(<br />))
    end

    test "basic custom element tag" do
      assert_equal %(custom_element { "Custom Element" }), convert_html(%(<custom-element>Custom Element</custom-element>))
    end

    test "tag with one attribute" do
      assert_equal %(div class: "app"), convert_html(%(<div class="app"></div>))
    end

    test "tag with multiple attributes" do
      assert_equal %(div class: "app", id: "body"), convert_html(%(<div class="app" id="body"></div>))
    end

    test "tag with attributes and single text node child" do
      assert_equal %{div(class: "app", id: "body") { "Text" }}, convert_html(%(<div class="app" id="body">Text</div>))
    end

    test "tag with one text node child" do
      assert_equal %(div { "Text" }), convert_html(%(<div>Text</div>))
    end

    test "tag with one text node child and long content" do
      expected = <<~HTML.strip
        div do
          "This is a super long text which exceeds the single line block limit"
        end
      HTML

      assert_equal expected, convert_html(%(<div>This is a super long text which exceeds the single line block limit</div>))
    end

    test "tag with attributes and mulitple children" do
      expected = <<~HTML.strip
        div(class: "app", id: "body") do
          h1 { "Title 1" }
          h2 do
            text "Title 2"
            span { "Small Addition" }
          end
        end
      HTML

      assert_equal expected, convert_html(%(<div class="app" id="body"><h1>Title 1</h1><h2>Title 2<span>Small Addition</span></h2></div>))
    end

    test "tag with mulitple text and element children" do
      expected = <<~HTML.strip
        div do
          text "Text"
          br
          text "Line 2"
        end
      HTML

      assert_equal expected, convert_html(%(<div>Text<br/>Line 2</div>))
    end

    test "tag with one tag node child" do
      expected = <<~HTML.strip
        div do
          span
        end
      HTML

      assert_equal expected, convert_html(%(<div><span></span></div>))
    end

    test "ERB method call" do
      expected = <<~HTML.strip
        div { some_method }
      HTML

      assert_equal expected, convert_html(%(<div><%= some_method %></div>))
    end

    test "ERB method call with long method name" do
      expected = <<~HTML.strip
        div do
          some_method_super_long_method_which_should_be_split_up
        end
      HTML

      assert_equal expected, convert_html(%(<div><%= some_method_super_long_method_which_should_be_split_up %></div>))
    end

    test "ERB interpolation" do
      expected = <<~HTML.strip
        div { "\#{some_method}_text" }
      HTML

      assert_equal expected, convert_html(%(<div><%= "\#{some_method}_text" %></div>))
    end

    test "ERB interpolation and text node" do
      expected = <<~HTML.strip
        div do
          text "\#{some_method}_text"
          text "More Text"
        end
      HTML

      assert_equal expected, convert_html(%(<div><%= "\#{some_method}_text" %> More Text</div>))
    end

    test "ERB loop" do
      expected = <<~HTML.strip
        @articles.each do |article|
          h1 { article.title }
        end
      HTML

      html = <<~HTML.strip
        <% @articles.each do |article| %>
          <h1><%= article.title %></h1>
        <% end %>
      HTML

      assert_equal expected, convert_html(html)
    end

    test "ERB if/else" do
      expected = <<~HTML.strip
        if some_condition.present?
          h1 { "Some Title" }
        elsif another_condition == "true"
          h1 { "Alternative Title" }
        else
          h1 { "Default Title" }
        end
      HTML

      html = <<~HTML.strip
        <% if some_condition.present? %>
          <h1><%= "Some Title" %></h1>
        <% elsif another_condition == "true" %>
          <h1><%= "Alternative Title" %></h1>
        <% else %>
          <h1><%= "Default Title" %></h1>
        <% end %>
      HTML

      assert_equal expected, convert_html(html)
    end

    test "ERB comment" do
      expected = <<~HTML.strip
        div do
          # The Next line has text in it
          text "More Text"
        end
      HTML

      assert_equal expected, convert_html(%(<div><%# The Next line has text in it %> More Text</div>))
    end

    test "ERB HTML safe output" do
      expected = <<~HTML.strip
        div { raw "<p>Some safe HTML</p>" }
      HTML

      assert_equal expected, convert_html(%(<div><%== "<p>Some safe HTML</p>" %></div>))
    end

    test "ERB HTML safe output and other erb output" do
      expected = <<~HTML.strip
        div do
          raw "<p>Some safe HTML</p>"
          text "Another output"
        end
      HTML

      assert_equal expected, convert_html(%(<div><%== "<p>Some safe HTML</p>" %><%= "Another output" %></div>))
    end
  end
end

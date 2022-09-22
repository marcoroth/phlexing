# frozen_string_literal: true

require "test_helper"

module Phlexing
  class ConverterTest < ActiveSupport::TestCase
    test "basic tags" do
      assert_phlex "div", %(<div></div>)
      assert_phlex "span", %(<span></span>)
      assert_phlex "p", %(<p></p>)
      assert_phlex "template_tag", %(<template></template>)
    end

    test "basic self closing tag" do
      assert_phlex %(img), %(<img />)
      assert_phlex %(br), %(<br />)
    end

    test "basic custom element tag" do
      html = %(<custom-element><custom-element>Custom Element</custom-element></custom-element>)

      expected = <<~HTML.strip
        custom_element do
          custom_element { "Custom Element" }
        end
      HTML

      assert_phlex expected, html
      assert_equal ["custom_element"], Phlexing::Converter.new(html).custom_elements.to_a
    end

    test "multiple custom element tags" do
      html = %(<first-element><second-element>Custom Element</second-element></first-element>)

      expected = <<~HTML.strip
        first_element do
          second_element { "Custom Element" }
        end
      HTML

      assert_phlex expected, html
      assert_equal %w[first_element second_element], Phlexing::Converter.new(html).custom_elements.to_a
    end

    test "tag with one attribute" do
      assert_phlex %(div class: "app"), %(<div class="app"></div>)
    end

    test "tag with multiple attributes" do
      assert_phlex %(div class: "app", id: "body"), %(<div class="app" id="body"></div>)
    end

    test "tag with attributes and single text node child" do
      assert_phlex %{div(class: "app", id: "body") { "Text" }}, %(<div class="app" id="body">Text</div>)
    end

    test "tag with one text node child" do
      assert_phlex %(div { "Text" }), %(<div>Text</div>)
    end

    test "tag with one text node child and long content" do
      expected = <<~HTML.strip
        div do
          "This is a super long text which exceeds the single line block limit"
        end
      HTML

      assert_phlex expected, %(<div>This is a super long text which exceeds the single line block limit</div>)
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

      assert_phlex expected, %(<div class="app" id="body"><h1>Title 1</h1><h2>Title 2<span>Small Addition</span></h2></div>)
    end

    test "tag with mulitple text and element children" do
      expected = <<~HTML.strip
        div do
          text "Text"
          br
          text "Line 2"
        end
      HTML

      assert_phlex expected, %(<div>Text<br />Line 2</div>)
    end

    test "tag with one tag node child" do
      expected = <<~HTML.strip
        div do
          span
        end
      HTML

      assert_phlex expected, %(<div><span></span></div>)
    end

    test "ERB method call" do
      expected = <<~HTML.strip
        div { some_method }
      HTML

      assert_phlex expected, %(<div><%= some_method %></div>)
    end

    test "ERB method call with long method name" do
      expected = <<~HTML.strip
        div do
          some_method_super_long_method_which_should_be_split_up
        end
      HTML

      assert_phlex expected, %(<div><%= some_method_super_long_method_which_should_be_split_up %></div>)
    end

    test "ERB interpolation" do
      expected = <<~HTML.strip
        div { "\#{some_method}_text" }
      HTML

      assert_phlex expected, %(<div><%= "\#{some_method}_text" %></div>)
    end

    test "ERB interpolation and text node" do
      expected = <<~HTML.strip
        div do
          text "\#{some_method}_text"
          text " More Text"
        end
      HTML

      assert_phlex expected, %(<div><%= "\#{some_method}_text" %> More Text</div>)
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

      assert_phlex expected, html
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

      assert_phlex expected, html
    end

    test "ERB comment" do
      expected = <<~HTML.strip
        div do
          # The Next line has text on it
          text " More Text"
        end
      HTML

      assert_phlex expected, %(<div><%# The Next line has text on it %> More Text</div>)
    end

    test "ERB HTML safe output" do
      skip

      expected = <<~HTML.strip
        div { raw "<p>Some safe HTML</p>" }
      HTML

      assert_phlex expected, %(<div><%== "<p>Some safe HTML</p>" %></div>)
    end

    test "ERB HTML safe output with siblings" do
      skip

      expected = <<~HTML.strip
        div do
          raw "<p>Some safe HTML</p>"
          text some_method
          span { "Text" }
        end
      HTML

      assert_phlex expected, %(<div><%== "<p>Some safe HTML</p>" %><%= some_method %><span> Text</span></div>)
    end

    test "ERB HTML safe output and other erb output" do
      skip

      expected = <<~HTML.strip
        div do
          raw "<p>Some safe HTML</p>"
          text "Another output"
        end
      HTML

      assert_phlex expected, %(<div><%== "<p>Some safe HTML</p>" %><%= "Another output" %></div>)
    end

    test "whitespace between HTML tag and text node" do
      expected = <<~HTML.strip
        a do
          i class: "fa fa-pencil"
          text " Edit"
        end
      HTML

      html = <<~HTML.strip
        <a><i class="fa fa-pencil"></i> Edit</a>
      HTML

      assert_phlex expected, html
    end

    test "whitespace between HTML tags" do
      expected = <<~HTML.strip
        a do
          i class: "fa fa-pencil"
          whitespace
          span { "Edit" }
        end
      HTML

      html = <<~HTML.strip
        <a><i class="fa fa-pencil"></i> <span>Edit</span></a>
      HTML

      assert_phlex expected, html
    end

    test "whitespace between ERB interpolations" do
      expected = <<~HTML.strip
        h1 do
          text @user.firstname
          whitespace
          text @user.lastname
        end
      HTML

      html = <<~HTML.strip
        <h1><%= @user.firstname %> <%= @user.lastname %></h1>
      HTML

      assert_phlex expected, html
    end

    test "whitespace around and in tags" do
      expected = <<~HTML.strip
        span do
          whitespace
          span { " 1 " }
          whitespace
          span { " 2 " }
          whitespace
        end
      HTML

      html = <<~HTML.strip
        <span> <span> 1 </span> <span> 2 </span> </span>
      HTML

      assert_phlex expected, html
    end
  end
end
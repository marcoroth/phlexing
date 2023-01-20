# frozen_string_literal: true

require_relative "../../test_helper"

class Phlexing::Converter::ErbTest < Minitest::Spec
  it "ERB method call" do
    expected = <<~HTML.strip
      div { some_method }
    HTML

    assert_phlex expected, %(<div><%= some_method %></div>) do
      assert_locals "some_method"
    end
  end

  it "ERB method call with long method name" do
    expected = <<~HTML.strip
      div do
        some_method_super_long_method_which_should_be_split_up
      end
    HTML

    assert_phlex expected, %(<div><%= some_method_super_long_method_which_should_be_split_up %></div>) do
      assert_locals "some_method_super_long_method_which_should_be_split_up"
    end
  end

  it "ERB interpolation" do
    expected = <<~HTML.strip
      div { "\#{some_method}_text" }
    HTML

    assert_phlex expected, %(<div><%= "\#{some_method}_text" %></div>) do
      assert_locals "some_method"
    end
  end

  it "ERB interpolation and text node" do
    expected = <<~HTML.strip
      div do
        text "\#{some_method}_text"
        text " More Text"
      end
    HTML

    assert_phlex expected, %(<div><%= "\#{some_method}_text" %> More Text</div>) do
      assert_locals "some_method"
    end
  end

  it "ERB loop" do
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

    assert_phlex expected, html do
      assert_ivars "articles"
      assert_locals
    end
  end

  it "ERB if/else" do
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

    assert_phlex expected, html do
      assert_locals "some_condition", "another_condition"
    end
  end

  it "ERB comment" do
    expected = <<~HTML.strip
      div do
        # The Next line has text on it
        text " More Text"
      end
    HTML

    assert_phlex expected, %(<div><%# The Next line has text on it %> More Text</div>)
  end

  it "ERB HTML safe output" do
    expected = <<~HTML.strip
      div { unsafe_raw "<p>Some safe HTML</p>" }
    HTML

    assert_phlex expected, %(<div><%== "<p>Some safe HTML</p>" %></div>)
  end

  it "ERB HTML safe output with siblings" do
    expected = <<~HTML.strip
      div do
        unsafe_raw "<p>Some safe HTML</p>"
        text some_method
        span { "Text" }
      end
    HTML

    assert_phlex expected, %(<div><%== "<p>Some safe HTML</p>" %><%= some_method %><span>Text</span></div>) do
      assert_locals "some_method"
    end
  end

  it "ERB HTML safe output and other erb output" do
    expected = <<~HTML.strip
      div do
        unsafe_raw "<p>Some safe HTML</p>"
        text "Another output"
      end
    HTML

    assert_phlex expected, %(<div><%== "<p>Some safe HTML</p>" %><%= "Another output" %></div>)
  end

  it "ERB capture" do
    expected = <<~HTML.strip
      @greeting = capture do
        text " Welcome to my shiny new web page! The date and time is "
        text Time.now
      end
    HTML

    html = <<~HTML.strip
      <% @greeting = capture do %>
        Welcome to my shiny new web page!  The date and time is
        <%= Time.now %>
      <% end %>
    HTML

    assert_phlex expected, html do
      assert_ivars "greeting"
    end
  end
end

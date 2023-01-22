# frozen_string_literal: true

require_relative "../../test_helper"

class Phlexing::Converter::ErbTest < Minitest::Spec
  it "ERB method call" do
    html = %(<div><%= some_method %></div>)

    expected = <<~PHLEX.strip
      div { some_method }
    PHLEX

    assert_phlex_template expected, html do
      assert_locals "some_method"
    end
  end

  it "ERB method call using <%- and -%>" do
    html = %(<div><%- some_method -%></div>)

    expected = <<~PHLEX.strip
      div { some_method }
    PHLEX

    assert_phlex_template expected, html
  end

  it "ERB method call using <%- and %>" do
    html = %(<div><%- some_method %></div>)

    expected = <<~PHLEX.strip
      div { some_method }
    PHLEX

    assert_phlex_template expected, html do
      assert_locals "some_method"
    end
  end

  it "ERB method call with long method name" do
    html = %(<div><%= some_method_super_long_method_which_should_be_split_up_and_wrapped_in_a_block %></div>)

    expected = <<~PHLEX.strip
      div do
        some_method_super_long_method_which_should_be_split_up_and_wrapped_in_a_block
      end
    PHLEX

    assert_phlex_template expected, html do
      assert_locals "some_method_super_long_method_which_should_be_split_up_and_wrapped_in_a_block"
    end
  end

  it "ERB interpolation" do
    html = %(<div><%= "\#{some_method}_text" %></div>)

    expected = <<~PHLEX.strip
      div { "\#{some_method}_text" }
    PHLEX

    assert_phlex_template expected, html do
      assert_locals "some_method"
    end
  end

  it "ERB interpolation and text node" do
    html = %(<div><%= "\#{some_method}_text" %> More Text</div>)

    expected = <<~PHLEX.strip
      div do
        text "\#{some_method}_text"
        text " More Text"
      end
    PHLEX

    assert_phlex_template expected, html do
      assert_locals "some_method"
    end
  end

  it "ERB loop" do
    html = <<~HTML.strip
      <% @articles.each do |article| %>
        <h1><%= article.title %></h1>
      <% end %>
    HTML

    expected = <<~PHLEX.strip
      @articles.each { |article| h1 { article.title } }
    PHLEX

    assert_phlex_template expected, html do
      assert_ivars "articles"
      assert_locals
    end
  end

  it "ERB if/else" do
    html = <<~HTML.strip
      <% if some_condition.present? %>
        <h1><%= "Some Title" %></h1>
      <% elsif another_condition == "true" %>
        <h1><%= "Alternative Title" %></h1>
      <% else %>
        <h1><%= "Default Title" %></h1>
      <% end %>
    HTML

    expected = <<~PHLEX.strip
      if some_condition.present?
        h1 { "Some Title" }
      elsif another_condition == "true"
        h1 { "Alternative Title" }
      else
        h1 { "Default Title" }
      end
    PHLEX

    assert_phlex_template expected, html do
      assert_locals "some_condition", "another_condition"
    end
  end

  it "ERB comment" do
    html = %(<div><%# The Next line has text on it %> More Text</div>)

    expected = <<~PHLEX.strip
      div do # The Next line has text on it
        text " More Text"
      end
    PHLEX

    assert_phlex_template expected, html
  end

  it "ERB HTML safe output" do
    html = %(<div><%== "<p>Some safe HTML</p>" %></div>)

    expected = <<~PHLEX.strip
      div { unsafe_raw "<p>Some safe HTML</p>" }
    PHLEX

    assert_phlex_template expected, html
  end

  it "ERB HTML safe output with siblings" do
    html = %(<div><%== "<p>Some safe HTML</p>" %><%= some_method %><span>Text</span></div>)

    expected = <<~PHLEX.strip
      div do
        unsafe_raw "<p>Some safe HTML</p>"
        text some_method
        span { "Text" }
      end
    PHLEX

    assert_phlex_template expected, html do
      assert_locals "some_method"
    end
  end

  it "ERB HTML safe output and other erb output" do
    html = %(<div><%== "<p>Some safe HTML</p>" %><%= "Another output" %></div>)

    expected = <<~PHLEX.strip
      div do
        unsafe_raw "<p>Some safe HTML</p>"
        text "Another output"
      end
    PHLEX

    assert_phlex_template expected, html
  end

  it "ERB capture" do
    html = <<~HTML.strip
      <% @greeting = capture do %>
        Welcome to my shiny new web page!  The date and time is
        <%= Time.now %>
      <% end %>
    HTML

    expected = <<~PHLEX.strip
      @greeting =
        capture do
          text " Welcome to my shiny new web page! The date and time is "
          text Time.now
        end
    PHLEX

    assert_phlex_template expected, html do
      assert_ivars "greeting"
    end
  end

  # rubocop:disable Lint/LiteralInInterpolation
  it "tag with text next to string erb output" do
    html = %(<div>Text<%= "ERB Text" %><%= "#{'interpolate'} text" %></div>)

    expected = <<~PHLEX.strip
      div do
        text "Text"
        text "ERB Text"
        text "#{'interpolate'} text"
      end
    PHLEX

    assert_phlex_template expected, html
  end
  # rubocop:enable Lint/LiteralInInterpolation
end

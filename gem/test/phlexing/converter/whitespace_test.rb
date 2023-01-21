# frozen_string_literal: true

require_relative "../../test_helper"

class Phlexing::Converter::WhitespaceTest < Minitest::Spec
  it "whitespace between HTML tag and text node" do
    html = <<~HTML.strip
      <a><i class="fa fa-pencil"></i> Edit</a>
    HTML

    expected = <<~PHLEX.strip
      a do
        i(class: "fa fa-pencil")
        text " Edit"
      end
    PHLEX

    assert_phlex_template expected, html
  end

  it "whitespace between HTML tags" do
    html = <<~HTML.strip
      <a><i class="fa fa-pencil"></i> <span>Edit</span></a>
    HTML

    expected = <<~PHLEX.strip
      a do
        i(class: "fa fa-pencil")
        whitespace
        span { "Edit" }
      end
    PHLEX

    assert_phlex_template expected, html
  end

  it "no whitespace between HTML tags when whitespace option disabled" do
    html = <<~HTML.strip
      <a><i class="fa fa-pencil"></i> <span>Edit</span></a>
    HTML

    expected = <<~PHLEX.strip
      a do
        i(class: "fa fa-pencil")
        span { "Edit" }
      end
    PHLEX

    assert_phlex_template expected, html, whitespace: false
  end

  it "whitespace between ERB interpolations" do
    html = <<~HTML.strip
      <h1><%= @user.firstname %> <%= @user.lastname %></h1>
    HTML

    expected = <<~PHLEX.strip
      h1 do
        text @user.firstname
        whitespace
        text @user.lastname
      end
    PHLEX

    assert_phlex_template expected, html do
      assert_ivars "user"
    end
  end

  it "no whitespace between ERB interpolations when whitespace option disabled" do
    html = <<~HTML.strip
      <h1><%= @user.firstname %> <%= @user.lastname %></h1>
    HTML

    expected = <<~PHLEX.strip
      h1 do
        text @user.firstname
        text @user.lastname
      end
    PHLEX

    assert_phlex_template expected, html, whitespace: false do
      assert_ivars "user"
    end
  end

  it "whitespace around and in tags" do
    html = <<~HTML.strip
      <span> <span> 1 </span> <span> 2 </span> </span>
    HTML

    expected = <<~PHLEX.strip
      span do
        whitespace
        span { " 1 " }
        whitespace
        span { " 2 " }
        whitespace
      end
    PHLEX

    assert_phlex_template expected, html
  end

  it "no whitespace around and in tags when whitespace option disabled" do
    html = <<~HTML.strip
      <span> <span> 1 </span> <span> 2 </span> </span>
    HTML

    expected = <<~PHLEX.strip
      span do
        span { " 1 " }
        span { " 2 " }
      end
    PHLEX

    assert_phlex_template expected, html, whitespace: false
  end
end

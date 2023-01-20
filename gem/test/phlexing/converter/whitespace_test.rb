# frozen_string_literal: true

require_relative "../../test_helper"

class Phlexing::Converter::WhitespaceTest < Minitest::Spec
  it "whitespace between HTML tag and text node" do
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

  it "whitespace between HTML tags" do
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

  it "no whitespace between HTML tags when whitespace option disabled" do
    expected = <<~HTML.strip
      a do
        i class: "fa fa-pencil"
        span { "Edit" }
      end
    HTML

    html = <<~HTML.strip
      <a><i class="fa fa-pencil"></i> <span>Edit</span></a>
    HTML

    assert_phlex expected, html, whitespace: false
  end

  it "whitespace between ERB interpolations" do
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

    assert_phlex expected, html do
      assert_ivars "user"
    end
  end

  it "no whitespace between ERB interpolations when whitespace option disabled" do
    expected = <<~HTML.strip
      h1 do
        text @user.firstname
        text @user.lastname
      end
    HTML

    html = <<~HTML.strip
      <h1><%= @user.firstname %> <%= @user.lastname %></h1>
    HTML

    assert_phlex expected, html, whitespace: false do
      assert_ivars "user"
    end
  end

  it "whitespace around and in tags" do
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

  it "no whitespace around and in tags when whitespace option disabled" do
    expected = <<~HTML.strip
      span do
        span { " 1 " }
        span { " 2 " }
      end
    HTML

    html = <<~HTML.strip
      <span> <span> 1 </span> <span> 2 </span> </span>
    HTML

    assert_phlex expected, html, whitespace: false
  end
end

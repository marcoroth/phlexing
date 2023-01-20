# frozen_string_literal: true

require_relative "../test_helper"

class Phlexing::ConverterTest < Minitest::Spec
  it "shouldn't pass render method call into the text method" do
    html = <<~HTML.strip
      <%= render SomeView.new %>
      Hello
    HTML

    expected = <<~PHLEX.strip
      render SomeView.new

      text "Hello"
    PHLEX

    assert_phlex expected, html
  end

  it "should generate phlex class with component name" do
    html = %(<h1>Hello World</h1>)

    expected = <<~PHLEX.strip
      class TestComponent < Phlex::HTML
        def template
          h1 { "Hello World" }
        end
      end
    PHLEX

    converter = Phlexing::Converter.new(html, phlex_class: true, component_name: "TestComponent")

    assert_equal expected, converter.component_code.strip
  end

  it "should generate phlex class with parent class name" do
    html = %(<h1>Hello World</h1>)

    expected = <<~PHLEX.strip
      class Component < ApplicationView
        def template
          h1 { "Hello World" }
        end
      end
    PHLEX

    converter = Phlexing::Converter.new(html, phlex_class: true, parent_component: "ApplicationView")

    assert_equal expected, converter.component_code.strip
  end

  it "should generate phlex class with parent class name and component name" do
    html = %(<h1>Hello World</h1>)

    expected = <<~PHLEX.strip
      class TestComponent < ApplicationView
        def template
          h1 { "Hello World" }
        end
      end
    PHLEX

    converter = Phlexing::Converter.new(html, phlex_class: true, component_name: "TestComponent", parent_component: "ApplicationView")

    assert_equal expected, converter.component_code.strip
  end

  it "should generate phlex class with ivars" do
    html = %(<h1><%= @firstname %> <%= @lastname %></h1>)

    expected = <<~PHLEX.strip
      class Component < Phlex::HTML
        def initialize(firstname:, lastname:)
          @firstname = firstname
          @lastname = lastname
        end

        def template
          h1 do
            text @firstname
            whitespace
            text @lastname
          end
        end
      end
    PHLEX

    converter = Phlexing::Converter.new(html, phlex_class: true)

    assert_equal expected, converter.component_code.strip
  end

  it "should generate phlex class with ivars, locals and ifs" do
    html = <<~HTML.strip
      <%= @user.name %>

      <% if show_company && @company %>
        <%= @company.name %>
      <% end %>

      <%= some_method %>
    HTML

    expected = <<~PHLEX.strip
      class Component < Phlex::HTML
        attr_accessor :show_company, :some_method

        def initialize(company:, show_company:, some_method:, user:)
          @company = company
          @show_company = show_company
          @some_method = some_method
          @user = user
        end

        def template
          text @user.name

          if show_company && @company
            whitespace
            text @company.name
          end

          text some_method
        end
      end
    PHLEX

    converter = Phlexing::Converter.new(html, phlex_class: true)

    assert_equal expected, converter.component_code.strip
  end
end

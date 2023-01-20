# frozen_string_literal: true

require_relative "../../test_helper"

class Phlexing::Converter::CustomElementsTest < Minitest::Spec
  it "basic custom element tags" do
    html = %(<c><d>Custom Element</d></c>)

    expected = <<~HTML.strip
      c do
        d { "Custom Element" }
      end
    HTML

    assert_phlex expected, html do
      assert_custom_elements "c", "d"
    end
  end

  it "basic custom element tag with dashes" do
    html = %(<custom-element-one><custom-element-two>Custom Element</custom-element-two></custom-element-one>)

    expected = <<~HTML.strip
      custom_element_one do
        custom_element_two { "Custom Element" }
      end
    HTML

    assert_phlex expected, html do
      assert_custom_elements "custom_element_one", "custom_element_two"
    end
  end

  it "multiple custom element tags" do
    html = %(<first-element><second-element>Custom Element</second-element></first-element>)

    expected = <<~HTML.strip
      first_element do
        second_element { "Custom Element" }
      end
    HTML

    assert_phlex expected, html do
      assert_custom_elements "first_element", "second_element"
    end
  end

  it "should generate phlex class with custom elements" do
    html = %(<my-custom>Hello<another-custom>World</another-custom></my-custom>)

    expected = <<~HTML.strip
      class Component < Phlex::HTML
        register_element :another_custom
        register_element :my_custom

        def template
          my_custom do
            text "Hello"
            another_custom { "World" }
          end
        end
      end
    HTML

    assert_equal expected, Phlexing::Converter.new(html, phlex_class: true).output.strip
  end

  it "should generate phlex class with custom elements and attr_accessors in alphabetical order" do
    html = %(<% users.each do |user| %><d><%= user.firstname %></d><c><%= abc %></c><% end %>)

    expected = <<~HTML.strip
      class Component < Phlex::HTML
        attr_accessor :abc, :users

        register_element :c
        register_element :d

        def initialize(abc:, users:)
          @abc = abc
          @users = users
        end

        def template
          users.each do |user|
            d { user.firstname }

            c { abc }
          end
        end
      end
    HTML

    assert_equal expected, Phlexing::Converter.new(html, phlex_class: true).output.strip
  end
end

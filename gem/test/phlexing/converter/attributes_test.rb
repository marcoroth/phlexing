# frozen_string_literal: true

require_relative "../../test_helper"

class Phlexing::Converter::AttributesTest < Minitest::Spec
  it "should interpolate ERB in attributes using <%=" do
    html = <<~HTML.strip
      <div class="<%= classes_helper %>">Text</div>
    HTML

    expected = <<~PHLEX.strip
      div(class: classes_helper) { "Text" }
    PHLEX

    assert_phlex_template expected, html do
      assert_locals "classes_helper"
    end
  end

  it "should interpolate ERB in multiple attributes using <%=" do
    html = <<~HTML.strip
      <div class="<%= classes_helper %>" style="<%= true? ? "background: red" : "background: blue" %>">Text</div>
    HTML

    expected = <<~PHLEX.strip
      div(
        class: classes_helper,
        style: (true? ? "background: red" : "background: blue")
      ) { "Text" }
    PHLEX

    assert_phlex_template expected, html do
      assert_locals "classes_helper"
      assert_instance_methods "true?"
    end
  end

  it "should not interpolate ERB in attributes using <%" do
    html = <<~HTML.strip
      <div class="<% classes_helper %>">Text</div>
    HTML

    expected = <<~PHLEX.strip
      div(class: %(\#{classes_helper && nil})) { "Text" }
    PHLEX

    assert_phlex_template expected, html do
      assert_locals "classes_helper"
    end
  end

  it "should interpolate ERB in attributes using <%= and if" do
    html = <<~HTML.strip
      <div class="<%= classes_helper if true %>">Text</div>
    HTML

    expected = <<~PHLEX.strip
      div(class: (classes_helper if true)) { "Text" }
    PHLEX

    assert_phlex_template expected, html do
      assert_locals "classes_helper"
    end
  end

  it "should interpolate ERB conditional in attribute" do
    html = <<~HTML.strip
      <div class="<%= something? ? "class-1" : "class-2" %>">Text</div>
    HTML

    expected = <<~PHLEX.strip
      div(class: (something? ? "class-1" : "class-2")) { "Text" }
    PHLEX

    assert_phlex_template expected, html do
      assert_instance_methods "something?"
    end
  end

  it "should interpolate ERB in tag" do
    html = <<~HTML.strip
      <input type="checkbox" <%= "selected" %> />
    HTML

    expected = <<~PHLEX.strip
      input(type: %(checkbox), **(" selected": true))
    PHLEX

    assert_phlex_template expected, html
  end

  xit "should interpolate ERB in tag with interpoltion" do
    html = '<input type="checkbox" <%= "data-#{Time.now.to_i}"%> />'
    expected = 'input(type: %(checkbox), **(" data-#{Time.now.to_i}": true))'
    assert_phlex_template expected, html
  end

  xit "should interpolate ERB in tag with conditional" do
    html = %(<input type="checkbox" <%= "selected" if true %> />)
    expected = %(input(type: %(checkbox), **(" selected": true)))

    assert_phlex_template expected, html
  end

  it "ERB attribute interpolation with one static and one dynamic string" do
    html = %(<div style="background: <%= blue? ? "blue" : "red" %>"></div>)

    expected = <<~PHLEX.strip
      div(style: %(background: \#{blue? ? "blue" : "red"}))
    PHLEX

    assert_phlex_template expected, html
  end

  it "ERB attribute interpolation with one dynamic string and one static string" do
    html = %(<div style="<%= "background: blue" %>; display: none;"></div>)

    expected = <<~PHLEX.strip
      div(style: %(\#{"background: blue"}; display: none;))
    PHLEX

    assert_phlex_template expected, html
  end

  xit "multiple ERB attribute string interpolations in one attribute" do
    html = %(<div style="<%= "background: red;" %> <%= "display: block;" %>"></div>)

    expected = <<~PHLEX.strip
      div(style: %(background: red; display: block;))
    PHLEX

    assert_phlex_template expected, html
  end

  it "multiple ERB attribute method interpolations in one attribute" do
    html = %(<div style="<%= background %><%= display %>"></div>)

    expected = <<~PHLEX.strip
      div(style: %(\#{background}\#{display}))
    PHLEX

    assert_phlex_template expected, html do
      assert_locals "background", "display"
    end
  end
end

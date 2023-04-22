# frozen_string_literal: true

require_relative "../../test_helper"

class Phlexing::Converter::SvgTest < Minitest::Spec
  it "converts SVG" do
    html = %(
      <svg>
        <path d="123"></path>
      </svg>
    )

    expected = <<~PHLEX.strip
      svg { |s| s.path(d: "123") }
    PHLEX

    assert_phlex_template expected, html
  end

  it "converts SVG with attributes" do
    html = %(
      <svg one="attribute" two="attributes">
        <path d="123"></path>
      </svg>
    )

    expected = <<~PHLEX.strip
      svg(one: "attribute", two: "attributes") { |s| s.path(d: "123") }
    PHLEX

    assert_phlex_template expected, html
  end

  it "converts SVG with ERB interpolation" do
    html = %(
      <svg one="<%= interpolate %>" two="<%= method_call(123) %>">
        <path d="123"></path>
      </svg>
    )

    expected = <<~PHLEX.strip
      svg(one: interpolate, two: method_call(123)) { |s| s.path(d: "123") }
    PHLEX

    assert_phlex_template expected, html do
      assert_locals "interpolate"
      assert_instance_methods "method_call"
    end
  end

  it "converts SVG with case-sensitive" do
    html = %(
      <svg>
        <feSpecularLighting>
          <fePointLight/>
        </feSpecularLighting>
      </svg>
    )

    expected = <<~PHLEX.strip
      svg { |s| s.feSpecularLighting { s.fePointLight } }
    PHLEX

    assert_phlex_template expected, html
  end

  it "nested SVG" do
    html = %(
      <svg xmlns="http://www.w3.org/2000/svg" version="1.1" width="5cm" height="5cm">
        <desc>Two groups, each of two rectangles</desc>
        <g id="group1" fill="red">
          <rect x="1cm" y="1cm" width="1cm" height="1cm"/>
          <rect x="3cm" y="1cm" width="1cm" height="1cm"/>
        </g>

        <g id="group2" fill="blue">
          <rect x="1cm" y="3cm" width="1cm" height="1cm"/>
          <rect x="3cm" y="3cm" width="1cm" height="1cm"/>
        </g>

        <rect x=".01cm" y=".01cm" width="4.98cm" height="4.98cm" fill="none" stroke="blue" stroke-width=".02cm"/>
      </svg>
    )

    expected = <<~PHLEX.strip
      svg(
        xmlns: "http://www.w3.org/2000/svg",
        version: "1.1",
        width: "5cm",
        height: "5cm"
      ) do |s|
        s.desc { "Two groups, each of two rectangles" }
        s.g(id: "group1", fill: "red") do
          s.rect(x: "1cm", y: "1cm", width: "1cm", height: "1cm")
          s.rect(x: "3cm", y: "1cm", width: "1cm", height: "1cm")
        end
        s.g(id: "group2", fill: "blue") do
          s.rect(x: "1cm", y: "3cm", width: "1cm", height: "1cm")
          s.rect(x: "3cm", y: "3cm", width: "1cm", height: "1cm")
        end
        s.rect(
          x: ".01cm",
          y: ".01cm",
          width: "4.98cm",
          height: "4.98cm",
          fill: "none",
          stroke: "blue",
          stroke_width: ".02cm"
        )
      end
    PHLEX

    assert_phlex_template expected, html
  end
end

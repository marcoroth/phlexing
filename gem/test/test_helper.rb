# frozen_string_literal: true

$LOAD_PATH.unshift File.expand_path("../lib", __dir__)

require "phlexing"
require "maxitest/autorun"

def convert_html(html, **options)
  Phlexing::Converter.new(html, **options).buffer.strip
end

def assert_phlex(expected, html, **options, &block)
  assert_equal(expected, convert_html(html, **options))

  @converter ||= Phlexing::Converter.new(html, **options)

  @assert_custom_elements_called = false
  @assert_ivars_called = false
  @assert_locals_called = false

  block&.call(self)

  assert_custom_elements unless @assert_custom_elements_called
  assert_ivars unless @assert_ivars_called
  assert_locals unless @assert_locals_called

  if options[:whitespace]
    assert_equal(
      Phlexing::Renderer::Erb.render(html),
      Phlexing::Renderer::Phlex.render(@converter)
    )
  end
end

def assert_custom_elements(*elements)
  raise "Make sure assert_custom_elements is called within the block passed to assert_phlex" if @converter.nil?

  @assert_custom_elements_called = true

  assert_equal(
    elements,
    @converter.custom_elements.to_a,
    "Phlex::Converter.custom_elements"
  )
end

def assert_ivars(*ivars)
  raise "Make sure assert_ivars is called within the block passed to assert_phlex" if @converter.nil?

  @assert_ivars_called = true

  assert_equal(
    ivars,
    @converter.ivars.to_a,
    "Phlex::Converter.ivars"
  )
end

def assert_locals(*locals)
  raise "Make sure assert_locals is called within the block passed to assert_phlex" if @converter.nil?

  @assert_locals_called = true

  assert_equal(
    locals,
    @converter.locals.to_a,
    "Phlex::Converter.locals"
  )
end

def assert_idents(*idents)
  raise "Make sure assert_idents is called within the block passed to assert_phlex" if @converter.nil?

  @assert_idents_called = true

  assert_equal(
    idents,
    @converter.idents.to_a,
    "Phlex::Converter.idents"
  )
end

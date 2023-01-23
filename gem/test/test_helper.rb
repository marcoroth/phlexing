# frozen_string_literal: true

$LOAD_PATH.unshift File.expand_path("../lib", __dir__)

require "phlexing"
require "maxitest/autorun"

def assert_phlex(expected, source, **options, &block)
  @converter = Phlexing::Converter.new(source, **options)

  assert_details(expected, source, @converter.component_code, &block)

  # assert_equal(
  #   Phlexing::Renderer::Erb.render(source),
  #   Phlexing::Renderer::Phlex.render(@converter.template_code)
  # )
end

def assert_phlex_template(expected, source, **options, &block)
  @converter = Phlexing::Converter.new(source, **options)

  assert_details(expected, source, @converter.template_code, &block)
end

def assert_details(expected, source, generated_code, &block)
  assert_equal(expected, generated_code)

  @analyzer = Phlexing::RubyAnalyzer.new
  @analyzer.analyze(source)

  @assert_custom_elements_called = false
  @assert_ivars_called = false
  @assert_locals_called = false
  @assert_idents_called = false

  block&.call(self)

  assert_custom_elements unless @assert_custom_elements_called
  assert_ivars unless @assert_ivars_called
  assert_locals unless @assert_locals_called
  # assert_idents unless @assert_idents_called
end

def assert_custom_elements(*elements)
  raise "Make sure assert_custom_elements is called within the block passed to assert_phlex" if @analyzer.nil?

  @assert_custom_elements_called = true

  assert_equal(
    elements.sort,
    @converter.custom_elements.to_a.sort,
    "assert_custom_elements"
  )
end

def assert_ivars(*ivars)
  raise "Make sure assert_ivars is called within the block passed to assert_phlex" if @analyzer.nil?

  @assert_ivars_called = true

  assert_equal(
    ivars.sort,
    @analyzer.ivars.to_a.sort,
    "assert_ivars"
  )
end

def assert_locals(*locals)
  raise "Make sure assert_locals is called within the block passed to assert_phlex" if @analyzer.nil?

  @assert_locals_called = true

  assert_equal(
    locals.sort,
    @analyzer.locals.to_a.sort,
    "assert_locals"
  )
end

def assert_idents(*idents)
  raise "Make sure assert_idents is called within the block passed to assert_phlex" if @analyzer.nil?

  @assert_idents_called = true

  assert_equal(
    idents.sort,
    @analyzer.idents.to_a.sort,
    "assert_idents"
  )
end

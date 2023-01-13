# frozen_string_literal: true

ENV["RAILS_ENV"] ||= "test"
require_relative "../config/environment"
require "rails/test_help"

require "phlex"

class ActiveSupport::TestCase
  # Run tests in parallel with specified workers
  parallelize(workers: :number_of_processors)

  # Setup all fixtures in test/fixtures/*.yml for all tests in alphabetical order.
  # fixtures :all

  def convert_html(html, **options)
    Phlexing::Converter.new(html, **options).buffer.strip
  end

  def assert_phlex(expected, html, **options, &block)
    assert_equal(expected, convert_html(html, **options))

    @converter ||= Phlexing::Converter.new(html, **options)

    block&.call(self)

    if options[:whitespace]
      assert_equal(
        Phlexing::Renderer::Erb.render(html),
        Phlexing::Renderer::Phlex.render(@converter)
      )
    end
  end

  def assert_custom_elements(*elements)
    raise "Make sure assert_custom_elements is called within the block passed to assert_phlex" if @converter.nil?

    assert_equal(
      elements,
      @converter.custom_elements.to_a
    )
  end

  def assert_erb_dependencies(*dependencies)
    raise "Make sure assert_erb_dependencies is called within the block passed to assert_phlex" if @converter.nil?

    assert_equal(
      dependencies,
      @converter.erb_dependencies.to_a
    )
  end
end

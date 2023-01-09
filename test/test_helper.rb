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

  def assert_phlex(expected, html, **options)
    assert_equal(expected, convert_html(html, **options))

    return unless options[:whitespace]

    converter = Phlexing::Converter.new(html, **options)

    assert_equal(
      Phlexing::Renderer::Erb.render(html),
      Phlexing::Renderer::Phlex.render(converter)
    )
  end
end

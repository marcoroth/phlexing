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

  def convert_html(html)
    Phlexing::Converter.new(html).buffer.strip
  end

  def assert_phlex(expected, html)
    assert_equal(expected, convert_html(html))

    erb = ERB.new(html)

    @articles = [OpenStruct.new(title: "1")]
    @user = OpenStruct.new(firstname: "1", lastname: "2")
    @users = [@user]

    assert_equal(erb.result(binding).squish, render_phlex(html).squish)
  end

  def method_missing(name)
    "method_call(:#{name})"
  end

  def respond_to_missing?
    true
  end

  def render_phlex(html)
    converter = Phlexing::Converter.new(html)

    elements = converter.custom_elements.to_a.map { |c| "register_element(:#{c})" }.join("\n")

    ruby = %{
      class TestComponent < Phlex::Component
        def initialize
          @articles = [OpenStruct.new(title: "1")]
          @user = OpenStruct.new(firstname: "1", lastname: "2")
          @users = [@user]
        end

        #{elements}

        def template
          #{converter.buffer}
        end

        def method_missing(name)
          "method_call(:\#{name})"
        end

        def respond_to_missing?
          true
        end
      end
    }

    # puts Rufo::Formatter.format(ruby)

    eval(ruby) # rubocop:disable Security/Eval

    TestComponent.new.call
  end
end

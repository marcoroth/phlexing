# frozen_string_literal: true

require "phlex"

module Phlexing
  module Renderer
    class Phlex
      def self.render(argument)
        case argument
        when String
          converter = Phlexing::Converter.new(argument)

          render_phlex(converter)
        when Phlexing::Converter
          render_phlex(argument)
        else
          throw
        end
      end

      def self.render_phlex(converter)
        elements = converter.custom_elements.to_a.map { |c| "register_element(:#{c})" }.join("\n")

        ruby = %{
          class TestComponent < ::Phlex::Component
            include ActionView::Helpers::TagHelper

            def initialize
              @articles = [OpenStruct.new(title: "Article 1"), OpenStruct.new(title: "Article 2")]
              @user = OpenStruct.new(firstname: "John", lastname: "Doe")
              @users = [@user, OpenStruct.new(firstname: "Jane", lastname: "Doe")]
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

        begin
          eval(ruby) # rubocop:disable Security/Eval

          TestComponent.new.call
        rescue SyntaxError, StandardError => e
          e.message
        end
      end
    end
  end
end

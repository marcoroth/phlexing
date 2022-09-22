# frozen_string_literal: true

require "phlex"

module Phlexing
  module Renderer
    class Phlex
      def self.render(argument)
        case argument
        when String
          converter = Phlexing::Converter.new(argument)

          render_phlex(converter.buffer, custom_elements: converter.custom_elements)
        when Phlexing::Converter
          render_phlex(argument.buffer, custom_elements: argument.custom_elements)
        else
          throw
        end
      end

      def self.render_phlex(template, custom_elements: [])
        elements = custom_elements.to_a.map { |c| "register_element(:#{c})" }.join("\n")

        view_helpers = "include ActionView::Helpers::TagHelper"
        component_name = "TestComponent#{Time.now.to_i}#{rand(10000)}"

        ruby = %{
          class #{component_name} < ::Phlex::Component
            #{view_helpers unless template.include?('raw')}

            def initialize
              @articles = [OpenStruct.new(title: "Article 1"), OpenStruct.new(title: "Article 2")]
              @user = OpenStruct.new(firstname: "John", lastname: "Doe")
              @users = [@user, OpenStruct.new(firstname: "Jane", lastname: "Doe")]
            end

            #{elements}

            def template
              #{template}
            end

            def method_missing(name)
              "method_call(:\#{name})"
            end

            def respond_to_missing?
              true
            end
          end

          #{component_name}
        }

        begin
          # puts Rufo::Formatter.format(ruby)
          clazz = eval(ruby) # rubocop:disable Security/Eval

          HtmlPress.press(clazz.new.call)
        rescue SyntaxError, StandardError => e
          e.message
        end
      end
    end
  end
end

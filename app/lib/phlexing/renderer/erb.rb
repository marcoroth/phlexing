# frozen_string_literal: true

module Phlexing
  module Renderer
    class Erb
      include ActionView::Helpers::TagHelper

      def self.render(html)
        new.render(html)
      end

      def render(html)
        erb = ::ERB.new(html)

        @articles = [OpenStruct.new(title: "Article 1"), OpenStruct.new(title: "Article 2")]
        @user = OpenStruct.new(firstname: "John", lastname: "Doe")
        @users = [@user, OpenStruct.new(firstname: "Jane", lastname: "Doe")]

        begin
          HtmlPress.press(erb.result(binding).squish)
        rescue SyntaxError, StandardError => e
          e.message
        end
      end

      def method_missing(name)
        "method_call(:#{name})"
      end

      def respond_to_missing?
        true
      end
    end
  end
end

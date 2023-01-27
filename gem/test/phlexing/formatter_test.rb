# frozen_string_literal: true

require_relative "../test_helper"

module Phlexing
  class FormatterTest < Minitest::Spec
    it "should init" do
      assert_equal "", Formatter.call(nil)
      assert_equal "", Formatter.call("")
    end

    it "should respect max option" do
      input = "call(rather_long_argument)"

      expected = <<~RUBY.strip
        call(
          rather_long_argument
        )
      RUBY

      assert_equal expected, Formatter.call(input, max: 25)
      assert_equal input, Formatter.call(input, max: 26)
    end
  end
end

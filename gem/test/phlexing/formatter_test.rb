# frozen_string_literal: true

require_relative "../test_helper"

module Phlexing
  class FormatterTest < Minitest::Spec
    it "should init" do
      assert_equal "", Formatter.format(nil)
      assert_equal "", Formatter.format("")
    end
  end
end

# frozen_string_literal: true

require_relative "../test_helper"

module Phlexing
  class MinifierTest < Minitest::Spec
    it "should init" do
      assert_equal "", Minifier.minify(nil)
      assert_equal "", Minifier.minify("")
    end
  end
end

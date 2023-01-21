# frozen_string_literal: true

require_relative "../test_helper"

module Phlexing
  class RubyAnalyzerTest < Minitest::Spec
    it "should handle nil" do
      analyzer = RubyAnalyzer.analyze(nil)

      assert_equal [], analyzer.ivars.to_a
      assert_equal [], analyzer.locals.to_a
      assert_equal [], analyzer.idents.to_a
    end

    it "should handle empty string" do
      analyzer = RubyAnalyzer.analyze("")

      assert_equal [], analyzer.ivars.to_a
      assert_equal [], analyzer.locals.to_a
      assert_equal [], analyzer.idents.to_a
    end
  end
end

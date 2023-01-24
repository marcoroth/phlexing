# frozen_string_literal: true

require_relative "../test_helper"

module Phlexing
  class RubyAnalyzerTest < Minitest::Spec
    it "should handle nil" do
      @analyzer = RubyAnalyzer.analyze(nil)

      assert_ivars
      assert_locals
      assert_idents
      assert_calls
      assert_consts
      assert_instance_methods
    end

    it "should handle empty string" do
      @analyzer = RubyAnalyzer.analyze("")

      assert_ivars
      assert_locals
      assert_idents
      assert_calls
      assert_consts
      assert_instance_methods
    end

    it "should handle local" do
      input = %(<% some %>)

      @analyzer = RubyAnalyzer.analyze(input)

      assert_ivars
      assert_locals "some"
      assert_idents
      assert_calls
      assert_consts
      assert_instance_methods
    end

    it "should handle method with parens" do
      input = %(<% some() %>)

      @analyzer = RubyAnalyzer.analyze(input)

      assert_ivars
      assert_locals
      assert_idents "some"
      assert_calls "some"
      assert_consts
      assert_instance_methods "some"
    end

    it "should handle method with parens and args" do
      input = %(<% some(@thing) %>)

      @analyzer = RubyAnalyzer.analyze(input)

      assert_ivars "thing"
      assert_locals
      assert_idents "some"
      assert_calls "some"
      assert_consts
      assert_instance_methods "some"
    end

    it "should handle local with questionmark" do
      input = %(<% some? %>)

      @analyzer = RubyAnalyzer.analyze(input)

      assert_ivars
      assert_locals
      assert_idents "some?"
      assert_calls "some?"
      assert_consts
      assert_instance_methods "some?"
    end

    it "should handle local with questionmark and parens" do
      input = %(<% some?() %>)

      @analyzer = RubyAnalyzer.analyze(input)

      assert_ivars
      assert_locals
      assert_idents "some?"
      assert_calls "some?"
      assert_consts
      assert_instance_methods "some?"
    end

    it "should handle local with questionmark and parens and arguments" do
      input = %(<% some?(@thing) %>)

      @analyzer = RubyAnalyzer.analyze(input)

      assert_ivars "thing"
      assert_locals
      assert_idents "some?"
      assert_calls "some?"
      assert_consts
      assert_instance_methods "some?"
    end

    it "should handle method call on local" do
      input = %(<% some.something %>)

      @analyzer = RubyAnalyzer.analyze(input)

      assert_ivars
      assert_locals "some"
      assert_idents "something"
      assert_calls "some"
      assert_consts
      assert_instance_methods
    end

    it "should handle method call with question mark on local" do
      input = %(<% some.something? %>)

      @analyzer = RubyAnalyzer.analyze(input)

      assert_ivars
      assert_locals "some"
      assert_idents "something?"
      assert_calls "some"
      assert_consts
      assert_instance_methods
    end

    it "should handle method call with block on local" do
      input = %(<%= tag.div do %>Content<% end %>)

      @analyzer = RubyAnalyzer.analyze(input)

      assert_ivars
      assert_locals "tag"
      assert_idents "div"
      assert_calls "tag"
      assert_consts
      assert_instance_methods
    end

    it "should handle method call on ivar" do
      input = %(<% @some.something? %>)

      @analyzer = RubyAnalyzer.analyze(input)

      assert_ivars "some"
      assert_locals
      assert_idents "something?"
      assert_calls "@some"
      assert_consts
      assert_instance_methods
    end

    it "should handle method call on Const" do
      input = %(<% Some.something? %>)

      @analyzer = RubyAnalyzer.analyze(input)

      assert_ivars
      assert_locals
      assert_idents "something?"
      assert_calls "Some"
      assert_consts "Some"
      assert_instance_methods
    end

    it "should handle method call on Const" do
      input = %(<%= content_tag :div do %>content<% end %>)

      @analyzer = RubyAnalyzer.analyze(input)

      assert_ivars
      assert_locals
      assert_idents "content_tag", "div"
      assert_calls
      assert_consts
      assert_instance_methods "content_tag"
    end
  end
end

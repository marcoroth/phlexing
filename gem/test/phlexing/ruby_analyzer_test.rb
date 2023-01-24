# frozen_string_literal: true

require_relative "../test_helper"

module Phlexing
  class RubyAnalyzerTest < Minitest::Spec
    it "should handle nil" do
      assert_analyzed(nil)
    end

    it "should handle empty string" do
      assert_analyzed("")
    end

    it "should handle local" do
      input = %(<% some %>)

      assert_analyzed(input) do
        assert_locals "some"
      end
    end

    it "should handle method with parens" do
      input = %(<% some() %>)

      assert_analyzed(input) do
        assert_idents "some"
        assert_calls "some"
        assert_instance_methods "some"
      end
    end

    it "should handle method with parens and args" do
      input = %(<% some(@thing) %>)

      assert_analyzed(input) do
        assert_ivars "thing"
        assert_idents "some"
        assert_calls "some"
        assert_instance_methods "some"
      end
    end

    it "should handle local with questionmark" do
      input = %(<% some? %>)

      assert_analyzed(input) do
        assert_idents "some?"
        assert_calls "some?"
        assert_instance_methods "some?"
      end
    end

    it "should handle local with questionmark and parens" do
      input = %(<% some?() %>)

      assert_analyzed(input) do
        assert_idents "some?"
        assert_calls "some?"
        assert_instance_methods "some?"
      end
    end

    it "should handle local with questionmark and parens and arguments" do
      input = %(<% some?(@thing) %>)

      assert_analyzed(input) do
        assert_ivars "thing"
        assert_idents "some?"
        assert_calls "some?"
        assert_instance_methods "some?"
      end
    end

    it "should handle method call on local" do
      input = %(<% some.something %>)

      assert_analyzed(input) do
        assert_locals "some"
        assert_idents "something"
        assert_calls "some"
      end
    end

    it "should handle method call with question mark on local" do
      input = %(<% some.something? %>)

      assert_analyzed(input) do
        assert_locals "some"
        assert_idents "something?"
        assert_calls "some"
      end
    end

    it "should handle method call with block on local" do
      input = %(<%= tag.div do %>Content<% end %>)

      assert_analyzed(input) do
        assert_locals "tag"
        assert_idents "div"
        assert_calls "tag"
      end
    end

    it "should handle method call on ivar" do
      input = %(<% @some.something? %>)

      assert_analyzed(input) do
        assert_ivars "some"
        assert_idents "something?"
        assert_calls "@some"
      end
    end

    it "should handle method call on Const" do
      input = %(<% Some.something? %>)

      assert_analyzed(input) do
        assert_idents "something?"
        assert_calls "Some"
        assert_consts "Some"
      end
    end

    it "should handle method call on Const" do
      input = %(<%= content_tag :div do %>content<% end %>)

      assert_analyzed(input) do
        assert_idents "content_tag", "div"
        assert_instance_methods "content_tag"
      end
    end
  end
end

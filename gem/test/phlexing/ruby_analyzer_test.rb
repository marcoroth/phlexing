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
        assert_idents "div"
        assert_calls "tag"
        assert_analyzer_includes "Phlex::Rails::Helpers::Tag"
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
        assert_idents "div"
        assert_analyzer_includes "Phlex::Rails::Helpers::ContentTag"
      end
    end

    it "should handle *_path route helper" do
      input = %(<%= user_path %>)

      assert_analyzed(input) do
        assert_analyzer_includes "Phlex::Rails::Helpers::Routes"
      end
    end

    it "should handle *_path route helper with argument" do
      input = %(<%= user_path(1) %>)

      assert_analyzed(input) do
        assert_analyzer_includes "Phlex::Rails::Helpers::Routes"
      end
    end

    it "should handle *_url route helper" do
      input = %(<%= user_url %>)

      assert_analyzed(input) do
        assert_analyzer_includes "Phlex::Rails::Helpers::Routes"
      end
    end

    it "should handle *_url route helper with argument" do
      input = %(<%= user_url(1) %>)

      assert_analyzed(input) do
        assert_analyzer_includes "Phlex::Rails::Helpers::Routes"
      end
    end
  end
end

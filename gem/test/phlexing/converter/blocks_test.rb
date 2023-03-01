# frozen_string_literal: true

require_relative "../../test_helper"

class Phlexing::Converter::BlocksTest < Minitest::Spec
  it "empty block" do
    html = %(<%= tag.div do %><% end %>)

    expected = <<~PHLEX.strip
      tag.div {}
    PHLEX

    assert_phlex_template expected, html do
      assert_locals "tag"
      assert_analyzer_includes "Phlex::Rails::Helpers::Tag"
    end
  end

  it "Rails tag helper with block and text" do
    html = %(<%= tag.div do %>Content<% end %>)

    expected = <<~PHLEX.strip
      tag.div { text "Content" }
    PHLEX

    assert_phlex_template expected, html do
      assert_locals "tag"
      assert_analyzer_includes "Phlex::Rails::Helpers::Tag"
    end
  end

  it "Rails tag helper with block and ERB output" do
    html = %(<%= tag.div do %><%= content %><% end %>)

    expected = <<~PHLEX.strip
      tag.div { text content }
    PHLEX

    assert_phlex_template expected, html do
      assert_locals "tag", "content"
      assert_analyzer_includes "Phlex::Rails::Helpers::Tag"
    end
  end
end

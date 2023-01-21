# frozen_string_literal: true

require_relative "../../test_helper"

class Phlexing::Converter::RailsHelpersTest < Minitest::Spec
  it "Rails tag helper with block and text" do
    html = %(<%= tag.div do %>Content<% end %>)

    expected = <<~PHLEX.strip
      tag.div { text "Content" }
    PHLEX

    assert_phlex_template expected, html do
      assert_locals "tag"
    end
  end

  it "Rails tag helper with block and ERB output" do
    html = %(<%= tag.div do %><%= content %><% end %>)

    expected = <<~PHLEX.strip
      tag.div { text content }
    PHLEX

    assert_phlex_template expected, html do
      assert_locals "tag", "content"
    end
  end

  it "Rails content_tag helper with block and text" do
    html = %(<%= content_tag :div do %>Content<% end %>)

    expected = <<~PHLEX.strip
      content_tag :div do
        text "Content"
      end
    PHLEX

    assert_phlex_template expected, html
  end

  it "Rails content_tag helper with block and attributes" do
    html = %(<%= content_tag :div, class: "container", data: { controller: "content" } do %>Content<% end %>)

    expected = <<~PHLEX.strip
      content_tag :div, class: "container", data: { controller: "content" } do
        text "Content"
      end
    PHLEX

    assert_phlex_template expected, html
  end

  it "Rails content_tag helper with block and ERB output" do
    html = %(<%= content_tag :div do %><%= content %><% end %>)

    expected = <<~PHLEX.strip
      content_tag :div do
        text content
      end
    PHLEX

    assert_phlex_template expected, html do
      assert_locals "content"
    end
  end

  it "Rails content_tag helper with block and ERB output" do
    html = %(<%= content_tag :div do %><%= content %><% end %>)

    expected = <<~PHLEX.strip
      content_tag :div do
        text content
      end
    PHLEX

    assert_phlex_template expected, html do
      assert_locals "content"
    end
  end

  it "Rails form_for helper with block and ERB output" do
    html = %(<%= form_for :article, @article do |f| %><%= f.blah %><% end %>)

    expected = <<~PHLEX.strip
      form_for :article, @article do |f|
        text f.blah
      end
    PHLEX

    assert_phlex_template expected, html do
      assert_ivars "article"
    end
  end

  it "Rails form_with helper with block and ERB output" do
    html = %(<%= form_with :article, @article do |f| %><%= f.blah %><% end %>)

    expected = <<~PHLEX.strip
      form_with :article, @article do |f|
        text f.blah
      end
    PHLEX

    assert_phlex_template expected, html do
      assert_ivars "article"
    end
  end

  it "Rails image_tag helper" do
    html = %(<%= image_tag image_path("/asset") %>Text)

    expected = <<~PHLEX.strip
      image_tag image_path("/asset")

      text "Text"
    PHLEX

    assert_phlex_template expected, html
  end

  it "Rails check_box_tag helper" do
    html = %(<%= check_box_tag(:pet_dog) %>Text)

    expected = <<~PHLEX.strip
      check_box_tag(:pet_dog)

      text "Text"
    PHLEX

    assert_phlex_template expected, html
  end

  it "Rails text_field helper" do
    html = %(<%= text_field(:person, :name) %>Text)

    expected = <<~PHLEX.strip
      text_field(:person, :name)

      text "Text"
    PHLEX

    assert_phlex_template expected, html
  end

  it "Rails options_for_select helper" do
    html = %(<%= options_for_select([['Lisbon', 1], ['Madrid', 2]]) %>Text)

    expected = <<~PHLEX.strip
      options_for_select([["Lisbon", 1], ["Madrid", 2]])

      text "Text"
    PHLEX

    assert_phlex_template expected, html
  end

  it "Rails collection_select helper" do
    html = %(<%= collection_select([]) %>Text)

    expected = <<~PHLEX.strip
      collection_select([])

      text "Text"
    PHLEX

    assert_phlex_template expected, html
  end

  it "Rails options_from_collection_for_select helper" do
    html = %(<%= options_from_collection_for_select([]) %>Text)

    expected = <<~PHLEX.strip
      options_from_collection_for_select([])

      text "Text"
    PHLEX

    assert_phlex_template expected, html
  end

  it "Rails select_date helper" do
    html = %(<%= select_date Date.today, prefix: :start_date %>Text)

    expected = <<~PHLEX.strip
      select_date Date.today, prefix: :start_date

      text "Text"
    PHLEX

    assert_phlex_template expected, html
  end

  it "Rails select_year helper" do
    html = %(<%= select_year(2009) %>Text)

    expected = <<~PHLEX.strip
      select_year(2009)

      text "Text"
    PHLEX

    assert_phlex_template expected, html
  end

  it "Rails link_to helper" do
    html = %(<%= link_to "Abc", user_path %>Text)

    expected = <<~PHLEX.strip
      link_to "Abc", user_path

      text "Text"
    PHLEX

    assert_phlex_template expected, html do
      assert_locals "user_path"
    end
  end

  it "Rails url_for helper" do
    html = %(<%= url_for post %>Text)

    expected = <<~PHLEX.strip
      url_for post

      text "Text"
    PHLEX

    assert_phlex_template expected, html do
      assert_locals "post"
    end
  end
end

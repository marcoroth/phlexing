# frozen_string_literal: true

require_relative "../../test_helper"

class Phlexing::Converter::RailsHelpersTest < Minitest::Spec
  it "Rails tag helper with block and text" do
    html = %(<%= tag.div do %>Content<% end %>)

    expected = <<~PHLEX.strip
      tag.div { plain "Content" }
    PHLEX

    assert_phlex_template expected, html do
      assert_analyzer_includes "Phlex::Rails::Helpers::Tag"
    end
  end

  it "Rails tag helper with block and ERB output" do
    html = %(<%= tag.div do %><%= content %><% end %>)

    expected = <<~PHLEX.strip
      tag.div { plain content }
    PHLEX

    assert_phlex_template expected, html do
      assert_locals "content"
      assert_analyzer_includes "Phlex::Rails::Helpers::Tag"
    end
  end

  it "Rails content_tag helper with block and text" do
    html = %(<%= content_tag :div do %>Content<% end %>)

    expected = <<~PHLEX.strip
      content_tag :div do
        plain "Content"
      end
    PHLEX

    assert_phlex_template expected, html do
      assert_analyzer_includes "Phlex::Rails::Helpers::ContentTag"
    end
  end

  it "Rails content_tag helper with block and attributes" do
    html = %(<%= content_tag :div, class: "container", data: { controller: "content" } do %>Content<% end %>)

    expected = <<~PHLEX.strip
      content_tag :div, class: "container", data: { controller: "content" } do
        plain "Content"
      end
    PHLEX

    assert_phlex_template expected, html do
      assert_analyzer_includes "Phlex::Rails::Helpers::ContentTag"
    end
  end

  it "Rails content_tag helper with block and ERB output" do
    html = %(<%= content_tag :div do %><%= content %><% end %>)

    expected = <<~PHLEX.strip
      content_tag :div do
        plain content
      end
    PHLEX

    assert_phlex_template expected, html do
      assert_locals "content"
      assert_analyzer_includes "Phlex::Rails::Helpers::ContentTag"
    end
  end

  it "Rails content_tag helper with block and ERB output" do
    html = %(<%= content_tag :div do %><%= content %><% end %>)

    expected = <<~PHLEX.strip
      content_tag :div do
        plain content
      end
    PHLEX

    assert_phlex_template expected, html do
      assert_locals "content"
      assert_analyzer_includes "Phlex::Rails::Helpers::ContentTag"
    end
  end

  it "Rails form_for helper with block and ERB output" do
    html = %(<%= form_for :article, @article do |f| %><%= f.blah %><% end %>)

    expected = <<~PHLEX.strip
      form_for :article, @article do |f|
        plain f.blah
      end
    PHLEX

    assert_phlex_template expected, html do
      assert_ivars "article"
      assert_analyzer_includes "Phlex::Rails::Helpers::FormFor"
    end
  end

  it "Rails form_with helper with block and ERB output" do
    html = %(<%= form_with :article, @article do |f| %><%= f.blah %><% end %>)

    expected = <<~PHLEX.strip
      form_with :article, @article do |f|
        plain f.blah
      end
    PHLEX

    assert_phlex_template expected, html do
      assert_ivars "article"
      assert_analyzer_includes "Phlex::Rails::Helpers::FormWith"
    end
  end

  it "Rails image_tag helper" do
    html = %(<%= image_tag image_path("/asset") %>Text)

    expected = <<~PHLEX.strip
      image_tag image_path("/asset")

      plain "Text"
    PHLEX

    assert_phlex_template expected, html do
      assert_analyzer_includes "Phlex::Rails::Helpers::ImagePath", "Phlex::Rails::Helpers::ImageTag"
    end
  end

  it "Rails check_box_tag helper" do
    html = %(<%= check_box_tag(:pet_dog) %>Text)

    expected = <<~PHLEX.strip
      check_box_tag(:pet_dog)

      plain "Text"
    PHLEX

    assert_phlex_template expected, html do
      assert_analyzer_includes "Phlex::Rails::Helpers::CheckboxTag"
    end
  end

  it "Rails text_field helper" do
    html = %(<%= text_field(:person, :name) %>Text)

    expected = <<~PHLEX.strip
      text_field(:person, :name)

      plain "Text"
    PHLEX

    assert_phlex_template expected, html do
      assert_analyzer_includes "Phlex::Rails::Helpers::TextField"
    end
  end

  it "Rails options_for_select helper" do
    html = %(<%= options_for_select([['Lisbon', 1], ['Madrid', 2]]) %>Text)

    expected = <<~PHLEX.strip
      options_for_select([["Lisbon", 1], ["Madrid", 2]])

      plain "Text"
    PHLEX

    assert_phlex_template expected, html do
      assert_analyzer_includes "Phlex::Rails::Helpers::OptionsForSelect"
    end
  end

  it "Rails collection_select helper" do
    html = %(<%= collection_select([]) %>Text)

    expected = <<~PHLEX.strip
      collection_select([])

      plain "Text"
    PHLEX

    assert_phlex_template expected, html do
      assert_analyzer_includes "Phlex::Rails::Helpers::CollectionSelect"
    end
  end

  it "Rails options_from_collection_for_select helper" do
    html = %(<%= options_from_collection_for_select([]) %>Text)

    expected = <<~PHLEX.strip
      options_from_collection_for_select([])

      plain "Text"
    PHLEX

    assert_phlex_template expected, html do
      assert_analyzer_includes "Phlex::Rails::Helpers::OptionsFromCollectionForSelect"
    end
  end

  it "Rails select_date helper" do
    html = %(<%= select_date Date.today, prefix: :start_date %>Text)

    expected = <<~PHLEX.strip
      select_date Date.today, prefix: :start_date

      plain "Text"
    PHLEX

    assert_phlex_template expected, html do
      assert_analyzer_includes "Phlex::Rails::Helpers::SelectDate"
      assert_consts "Date"
    end
  end

  it "Rails select_year helper" do
    html = %(<%= select_year(2009) %>Text)

    expected = <<~PHLEX.strip
      select_year(2009)

      plain "Text"
    PHLEX

    assert_phlex_template expected, html do
      assert_analyzer_includes "Phlex::Rails::Helpers::SelectYear"
    end
  end

  it "Rails link_to helper" do
    html = %(<%= link_to "Abc", "/users" %>Text)

    expected = <<~PHLEX.strip
      link_to "Abc", "/users"

      plain "Text"
    PHLEX

    assert_phlex_template expected, html do
      assert_analyzer_includes "Phlex::Rails::Helpers::LinkTo"
    end
  end

  it "Rails url_for helper" do
    html = %(<%= url_for post %>Text)

    expected = <<~PHLEX.strip
      url_for post

      plain "Text"
    PHLEX

    assert_phlex_template expected, html do
      assert_locals "post"
      assert_analyzer_includes "Phlex::Rails::Helpers::URLFor"
    end
  end

  it "Rails content_for helper" do
    html = <<~ERB.strip
      <ul><%= content_for :navigation %></ul>
      Text
    ERB

    expected = <<~PHLEX.strip
      ul { content_for :navigation }

      plain "Text"
    PHLEX

    assert_phlex_template expected, html do
      assert_analyzer_includes "Phlex::Rails::Helpers::ContentFor"
    end
  end

  it "Rails content_for helper with block" do
    html = <<~ERB.strip
      <% content_for :navigation do %>
        <li><%= link_to 'Home', action: 'index' %></li>
      <% end %>
      Text
    ERB

    expected = <<~PHLEX.strip
      content_for :navigation do
        li { link_to "Home", action: "index" }
      end

      plain "Text"
    PHLEX

    assert_phlex_template expected, html do
      assert_analyzer_includes "Phlex::Rails::Helpers::ContentFor", "Phlex::Rails::Helpers::LinkTo"
    end
  end

  it "Rails t helper" do
    html = %(<%= t("hello") %>Text)

    expected = <<~PHLEX.strip
      t("hello")

      plain "Text"
    PHLEX

    assert_phlex_template expected, html do
      assert_analyzer_includes "Phlex::Rails::Helpers::T"
    end
  end

  it "Rails translate helper" do
    html = %(<%= translate("hello") %>Text)

    expected = <<~PHLEX.strip
      translate("hello")

      plain "Text"
    PHLEX

    assert_phlex_template expected, html do
      assert_analyzer_includes "Phlex::Rails::Helpers::Translate"
    end
  end

  it "Rails radio_button helper" do
    html = %(<%= radio_button("hello") %>Text)

    expected = <<~PHLEX.strip
      radio_button("hello")

      plain "Text"
    PHLEX

    assert_phlex_template expected, html do
      assert_analyzer_includes "Phlex::Rails::Helpers::RadioButton"
    end
  end

  it "Rails stylesheet_path helper" do
    html = %(<%= stylesheet_path "hello" %>Text)

    expected = <<~PHLEX.strip
      stylesheet_path "hello"

      plain "Text"
    PHLEX

    assert_phlex_template expected, html do
      assert_analyzer_includes "Phlex::Rails::Helpers::StyleSheetPath"
    end
  end

  it "Rails javascript_path helper" do
    html = %(<%= javascript_path "hello" %>Text)

    expected = <<~PHLEX.strip
      javascript_path "hello"

      plain "Text"
    PHLEX

    assert_phlex_template expected, html do
      assert_analyzer_includes "Phlex::Rails::Helpers::JavaScriptPath"
    end
  end

  it "Rails dom_id helper" do
    html = %(<%= dom_id "hello" %>Text)

    expected = <<~PHLEX.strip
      dom_id "hello"

      plain "Text"
    PHLEX

    assert_phlex_template expected, html do
      assert_analyzer_includes "Phlex::Rails::Helpers::DOMID"
    end
  end

  it "should include rails helpers in component" do
    html = %(<%= translate("hello") %>)

    expected = <<~PHLEX.strip
      class Component < Phlex::HTML
        include Phlex::Rails::Helpers::Translate

        def view_template
          translate("hello")
        end
      end
    PHLEX

    assert_phlex expected, html do
      assert_analyzer_includes "Phlex::Rails::Helpers::Translate"
    end
  end

  it "should include multiple rails helpers in component" do
    html = %(<%= translate("hello") %><%= t("hello") %>)

    expected = <<~PHLEX.strip
      class Component < Phlex::HTML
        include Phlex::Rails::Helpers::T
        include Phlex::Rails::Helpers::Translate

        def view_template
          translate("hello")

          t("hello")
        end
      end
    PHLEX

    assert_phlex expected, html do
      assert_analyzer_includes "Phlex::Rails::Helpers::Translate", "Phlex::Rails::Helpers::T"
    end
  end
end

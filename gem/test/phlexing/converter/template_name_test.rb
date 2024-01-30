# frozen_string_literal: true

require_relative "../../test_helper"

class Phlexing::Converter::TemplateNameTest < Minitest::Spec
  it "defaults to 'view_template'" do
    expected = <<~PHLEX.strip
      class Component < Phlex::HTML
        def view_template
        end
      end
    PHLEX

    assert_phlex expected, ""
  end

  it "accepts other value" do
    expected = <<~PHLEX.strip
      class Component < Phlex::HTML
        def template
        end
      end
    PHLEX

    assert_phlex expected, "", template_name: "template"
  end
end

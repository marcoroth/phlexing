# frozen_string_literal: true

require_relative "../test_helper"

class Phlexing::ConverterTest < Minitest::Spec
  it "shouldn't pass render method call into the text method" do
    html = <<~HTML.strip
      <%= render SomeView.new %>
      Hello
    HTML

    expected = <<~PHLEX.strip
      render SomeView.new

      text "Hello"
    PHLEX

    assert_phlex_template expected, html do
      assert_consts "SomeView"
      assert_instance_methods "render"
    end
  end

  it "should generate phlex class with component name" do
    html = %(<h1>Hello World</h1>)

    expected = <<~PHLEX.strip
      class TestComponent < Phlex::HTML
        def template
          h1 { "Hello World" }
        end
      end
    PHLEX

    assert_phlex expected, html, component_name: "TestComponent"
  end

  it "should generate phlex class with parent class name" do
    html = %(<h1>Hello World</h1>)

    expected = <<~PHLEX.strip
      class Component < ApplicationView
        def template
          h1 { "Hello World" }
        end
      end
    PHLEX

    assert_phlex expected, html, parent_component: "ApplicationView"
  end

  it "should generate phlex class with parent class name and component name" do
    html = %(<h1>Hello World</h1>)

    expected = <<~PHLEX.strip
      class TestComponent < ApplicationView
        def template
          h1 { "Hello World" }
        end
      end
    PHLEX

    assert_phlex expected, html, component_name: "TestComponent", parent_component: "ApplicationView"
  end

  it "should generate phlex class with ivars" do
    html = %(<h1><%= @firstname %> <%= @lastname %></h1>)

    expected = <<~PHLEX.strip
      class Component < Phlex::HTML
        def initialize(firstname:, lastname:)
          @firstname = firstname
          @lastname = lastname
        end

        def template
          h1 do
            text @firstname
            whitespace
            text @lastname
          end
        end
      end
    PHLEX

    assert_phlex expected, html do
      assert_ivars "firstname", "lastname"
    end
  end

  it "should generate phlex class with ivars, locals and ifs" do
    html = <<~HTML.strip
      <%= @user.name %>

      <% if show_company && @company %>
        <%= @company.name %>
      <% end %>

      <%= some_method %>
    HTML

    expected = <<~PHLEX.strip
      class Component < Phlex::HTML
        attr_accessor :show_company, :some_method

        def initialize(company:, show_company:, some_method:, user:)
          @company = company
          @show_company = show_company
          @some_method = some_method
          @user = user
        end

        def template
          text @user.name

          if show_company && @company
            whitespace
            text @company.name
          end

          text some_method
        end
      end
    PHLEX

    assert_phlex expected, html do
      assert_ivars "company", "user"
      assert_locals "show_company", "some_method"
    end
  end

  it "should detect ivars in ERB interpolated HTML attribute" do
    html = %(<div class="<%= @classes %>"></div>)

    expected = <<~PHLEX.strip
      class Component < Phlex::HTML
        def initialize(classes:)
          @classes = classes
        end

        def template
          div(class: @classes)
        end
      end
    PHLEX

    assert_phlex expected, html do
      assert_ivars "classes"
    end
  end

  it "should detect locals in ERB interpolated HTML attribute" do
    html = %(<div class="<%= classes %>"></div>)

    expected = <<~PHLEX.strip
      class Component < Phlex::HTML
        attr_accessor :classes

        def initialize(classes:)
          @classes = classes
        end

        def template
          div(class: classes)
        end
      end
    PHLEX

    assert_phlex expected, html do
      assert_locals "classes"
    end
  end

  it "should detect method call in ERB interpolated HTML attribute" do
    html = %(<div class="<%= some_helper(with: :args) %>"></div>)

    expected = <<~PHLEX.strip
      class Component < Phlex::HTML
        def template
          div(class: (some_helper(with: :args)))
        end

        private

        def some_helper(*args, **kwargs)
          # TODO: Implement me
        end
      end
    PHLEX

    assert_phlex expected, html do
      assert_instance_methods "some_helper"
    end
  end

  it "should render private instance methods" do
    html = %(<% if should_show? %><%= pretty_print(@user) %><%= another_helper(1) %><% end %>)

    expected = <<~PHLEX.strip
      class Component < Phlex::HTML
        def initialize(user:)
          @user = user
        end

        def template
          if should_show?
            text pretty_print(@user)

            text another_helper(1)
          end
        end

        private

        def another_helper(*args, **kwargs)
          # TODO: Implement me
        end

        def pretty_print(*args, **kwargs)
          # TODO: Implement me
        end

        def should_show?(*args, **kwargs)
          # TODO: Implement me
        end
      end
    PHLEX

    assert_phlex expected, html do
      assert_ivars "user"
      assert_instance_methods "another_helper", "pretty_print", "should_show?"
    end
  end

  it "should method call on object in ERB interpolated HTML attribute" do
    html = %(<div class="<%= Router.user_path(user) %>"></div>)

    expected = <<~PHLEX.strip
      class Component < Phlex::HTML
        include Phlex::Rails::Helpers::Routes

        attr_accessor :user

        def initialize(user:)
          @user = user
        end

        def template
          div(class: Router.user_path(user))
        end
      end
    PHLEX

    assert_phlex expected, html do
      assert_consts "Router"
      assert_locals "user"
      assert_analyzer_includes "Phlex::Rails::Helpers::Routes"
    end
  end
end

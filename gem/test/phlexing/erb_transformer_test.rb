# frozen_string_literal: true

require_relative "../test_helper"

module Phlexing
  class ErbTransformerTest < Minitest::Spec
    it "should init" do
      assert_equal "", ErbTransformer.transform(nil)
      assert_equal "", ErbTransformer.transform("")
    end

    it "should transform template tag" do
      assert_equal "<template-tag></template-tag>", ErbTransformer.transform(%(<template></template>))
      assert_equal "<template-tag><div>Text</div></template-tag>", ErbTransformer.transform(%(<template><div>Text</div></template>))
      assert_equal %(<template-tag attribute="value"><div>Text</div></template-tag>), ErbTransformer.transform(%(<template attribute="value"><div>Text</div></template>))
    end

    it "should transform newlines" do
      assert_equal "<div>          <span>123</span>        </div>", ErbTransformer.transform(<<-HTML)
        <div>
          <span>123</span>
        </div>
      HTML
    end

    it "should transform erb" do
      input = %(<div><% "The Next line has text on it" %> More Text</div>  )
      expected = %(<div><erb silent> "The Next line has text on it" </erb> More Text</div>)

      assert_equal expected, ErbTransformer.transform(input)
    end

    it "should transform erb output" do
      input = %(<div><%= "The Next line has text on it" %> More Text</div>  )
      expected = %(<div><erb loud> "The Next line has text on it" </erb> More Text</div>)

      assert_equal expected, ErbTransformer.transform(input)
    end

    it "should transform erb comment" do
      input = %(<div><%# The Next line has text on it %> More Text</div>  )
      expected = %(<div><erb silent># The Next line has text on it </erb> More Text</div>)

      assert_equal expected, ErbTransformer.transform(input)
    end

    it "should transform erb with whitespace and multiple children in div" do
      input = %(<div><%= @firstname %> <%= @lastname %></div>)
      expected = %(<div><erb loud> @firstname </erb> <erb loud> @lastname </erb></div>)

      assert_equal expected, ErbTransformer.transform(input)
    end

    it "should transform erb with whitespace and multiple children in span" do
      input = %(<span><%= @firstname %> <%= @lastname %></span>)
      expected = %(<span><erb loud> @firstname </erb> <erb loud> @lastname </erb></span>)

      assert_equal expected, ErbTransformer.transform(input)
    end

    it "should transform erb with whitespace and multiple children in h1" do
      input = %(<h1><%= @firstname %> <%= @lastname %></h1>)
      expected = %(<h1><erb loud> @firstname </erb> <erb loud> @lastname </erb></h1>)

      assert_equal expected, ErbTransformer.transform(input)
    end
  end
end

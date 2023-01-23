# frozen_string_literal: true

require_relative "../test_helper"

module Phlexing
  class ERBTransformerTest < Minitest::Spec
    it "should init" do
      assert_equal "", ERBTransformer.call(nil)
      assert_equal "", ERBTransformer.call("")
    end

    it "should transform template tag" do
      assert_equal "<template-tag></template-tag>", ERBTransformer.call(%(<template></template>))
      assert_equal "<template-tag><div>Text</div></template-tag>", ERBTransformer.call(%(<template><div>Text</div></template>))
      assert_equal %(<template-tag attribute="value"><div>Text</div></template-tag>), ERBTransformer.call(%(<template attribute="value"><div>Text</div></template>))
    end

    it "should transform newlines" do
      assert_equal "<div>          <span>123</span>        </div>", ERBTransformer.call(<<-HTML)
        <div>
          <span>123</span>
        </div>
      HTML
    end

    it "should transform erb" do
      input = %(<div><% "The Next line has text on it" %> More Text</div>  )
      expected = %(<div><erb silent> &quot;The Next line has text on it&quot; </erb> More Text</div>)

      assert_equal expected, ERBTransformer.call(input)
    end

    it "should transform erb output" do
      input = %(<div><%= "The Next line has text on it" %> More Text</div>  )
      expected = %(<div><erb loud> &quot;The Next line has text on it&quot; </erb> More Text</div>)

      assert_equal expected, ERBTransformer.call(input)
    end

    it "should transform erb comment" do
      input = %(<div><%# The Next line has text on it %> More Text</div>  )
      expected = %(<div><erb silent># The Next line has text on it </erb> More Text</div>)

      assert_equal expected, ERBTransformer.call(input)
    end

    it "should transform erb with whitespace and multiple children in div" do
      input = %(<div><%= @firstname %> <%= @lastname %></div>)
      expected = %(<div><erb loud> @firstname </erb> <erb loud> @lastname </erb></div>)

      assert_equal expected, ERBTransformer.call(input)
    end

    it "should transform erb with whitespace and multiple children in span" do
      input = %(<span><%= @firstname %> <%= @lastname %></span>)
      expected = %(<span><erb loud> @firstname </erb> <erb loud> @lastname </erb></span>)

      assert_equal expected, ERBTransformer.call(input)
    end

    it "should transform erb with whitespace and multiple children in h1" do
      input = %(<h1><%= @firstname %> <%= @lastname %></h1>)
      expected = %(<h1><erb loud> @firstname </erb> <erb loud> @lastname </erb></h1>)

      assert_equal expected, ERBTransformer.call(input)
    end
  end
end

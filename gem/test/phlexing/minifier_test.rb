# frozen_string_literal: true

require_relative "../test_helper"

module Phlexing
  class MinifierTest < Minitest::Spec
    it "should init" do
      assert_equal "", Minifier.call(nil)
      assert_equal "", Minifier.call("")
    end

    it "should minify erb" do
      input = %(  <div>   <erb silent=""> The Next line has text on it </erb>   More Text  </div>   )
      expected = %(<div> <erb silent=""> The Next line has text on it </erb> More Text</div>)

      assert_equal expected, Minifier.call(input)
    end

    it "should minify erb output" do
      input = %(  <div>      <erb loud="">    The Next line has text on it   </erb>     More Text    </div>         )
      expected = %(<div> <erb loud=""> The Next line has text on it </erb> More Text</div>)

      assert_equal expected, Minifier.call(input)
    end

    it "should minify erb comment" do
      input = %(     <div>        <erb silent="">        The Next line has text on it        </erb>    More Text   </div>  )
      expected = %(<div> <erb silent=""> The Next line has text on it </erb> More Text</div>)
      assert_equal expected, Minifier.call(input)
    end

    it "should minify erb interpolation with whitespace in div" do
      input = %(<div><%= @firstname %> <%= @lastname %></div>)
      expected = %(<div><%= @firstname %> <%= @lastname %></div>)

      assert_equal expected, Minifier.call(input)
    end

    it "should minify erb interpolation with whitespace in h1" do
      input = %(<h1><%= @firstname %> <%= @lastname %></h1>)
      expected = %(<h1><%= @firstname %> <%= @lastname %></h1>)

      assert_equal expected, Minifier.call(input)
    end

    it "should minify erb interpolation with whitespace and newline in div" do
      input = <<-HTML

        <div>
          <%= @firstname %>

          <%= @lastname %>
        </div>

      HTML

      expected = %(<div> <%= @firstname %><%= @lastname %></div>)
      assert_equal expected, Minifier.call(input)
    end

    it "should minify erb interpolation with whitespace in span" do
      input = %(<span><%= @firstname %> <%= @lastname %></span>)
      expected = %(<span><%= @firstname %> <%= @lastname %></span>)

      assert_equal expected, Minifier.call(input)
    end

    it "should minify erb interpolation with whitespace and newline in span" do
      input = <<-HTML

        <span>
          <%= @firstname %>

          <%= @lastname %>
        </span>

      HTML

      expected = %(<span> <%= @firstname %><%= @lastname %> </span>)
      assert_equal expected, Minifier.call(input)
    end

    it "should not strip comments" do
      input = %(     <!--   I'm a comment   -->   )
      expected = %(<!-- I'm a comment -->)
      assert_equal expected, Minifier.call(input)
    end

    it "should minify with whitespace and newlines" do
      input = <<-HTML

        <div>
          <span>   123   </span>
        </div>

      HTML

      expected = %(<div> <span> 123 </span></div>)

      assert_equal expected, Minifier.call(input)
    end

    it "should not minify alpine.js attributes" do
      input = %(<button @click.prevent="something">Button</button>)
      expected = %(<button @click.prevent="something">Button</button>)

      assert_equal expected, Minifier.call(input)

      input = %(<button @click.prevent='something'>Button</button>)
      expected = %(<button @click.prevent='something'>Button</button>)

      assert_equal expected, Minifier.call(input)
    end

    xit "should properly minify attribute interpolation" do
      input = %(<input type="checkbox" <%= "selected" %> />)
      expected = %(<input type="checkbox" <%= "selected" %> />)

      assert_equal expected, Minifier.call(input)
    end
  end
end

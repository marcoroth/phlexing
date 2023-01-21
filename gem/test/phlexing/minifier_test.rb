# frozen_string_literal: true

require_relative "../test_helper"

module Phlexing
  class MinifierTest < Minitest::Spec
    it "should init" do
      assert_equal "", Minifier.minify(nil)
      assert_equal "", Minifier.minify("")
    end

    it "should minify erb" do
      input = %(  <div>   <erb silent=""> The Next line has text on it </erb>   More Text  </div>   )
      expected = %(<div><erb silent=""> The Next line has text on it </erb> More Text</div>)

      assert_equal expected, Minifier.minify(input)
    end

    it "should minify erb output" do
      input = %(  <div>      <erb loud="">    The Next line has text on it   </erb>     More Text    </div>         )
      expected = %(<div><erb loud=""> The Next line has text on it </erb> More Text</div>)

      assert_equal expected, Minifier.minify(input)
    end

    it "should minify erb comment" do
      input = %(     <div>        <erb silent="">        The Next line has text on it        </erb>    More Text   </div>  )
      expected = %(<div><erb silent=""> The Next line has text on it </erb> More Text</div>)
      assert_equal expected, Minifier.minify(input)
    end
  end
end

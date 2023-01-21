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
      assert_equal "        <div>          <span>123</span>        </div>", ErbTransformer.transform(<<-HTML)
        <div>
          <span>123</span>
        </div>
      HTML
    end
  end
end

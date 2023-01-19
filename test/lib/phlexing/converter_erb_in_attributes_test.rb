# frozen_string_literal: true

require "test_helper"

require "phlexing"

module Phlexing
  class ConverterErbInAttributesTest < ActiveSupport::TestCase
    test "should handle ERB within HTML attributes" do
      html = %(<div class="<%= @classes ? "one" : "two" %>">Hello</div>)
      html = %(<div class="<%= dom_id(post) %>">Hello</div>)

      doc = Nokogiri.parse(html)
      doc2 = Html2haml::HTML.new(html).instance_variable_get(:@template)



      def process_node(node)
        node.attributes.each do |name, value|

          if value.include?("<%")
            puts node.attributes[name].value
            node.attributes[name].value = value.gsub("<%", "{PHLEXING:ERB:OUTPUT:OPEN}").gsub("%>", "{PHLEXING:ERB:OUTPUT:CLOSE}")
            puts node.attributes[name].value
            puts "======="
          end
        end
      end

      doc2.children.each { process_node(_1) }





      assert_equal %(<div class="{PHLEXING:ERB:OUTPUT:OPEN}= dom_id(post) {PHLEXING:ERB:OUTPUT:CLOSE}">Hello</div>), doc2.to_html
      # assert_equal doc.to_html, html
    end
  end
end

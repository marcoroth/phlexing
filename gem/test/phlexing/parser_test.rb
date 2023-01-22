# frozen_string_literal: true

require_relative "../test_helper"

def assert_dom_equal(expected, actual)
  assert_equal expected, actual.gsub(%(<!DOCTYPE html PUBLIC \"-//W3C//DTD HTML 4.0 Transitional//EN\" \"http://www.w3.org/TR/REC-html40/loose.dtd\">), "").squish
end

module Phlexing
  class ParserTest < Minitest::Spec
    before(:each) do
      @nodes = []
    end

    def extract_children(node)
      @nodes << node.name

      if node&.children
        node.children.each do |node|
          extract_children(node)
        end
      end

      @nodes
    end

    it "should handle nil" do
      parser = Parser.parse(nil)

      assert_equal "#document-fragment", extract_children(parser).join(",")
      assert_dom_equal "", parser.to_xml
      assert_equal Nokogiri::HTML4::DocumentFragment, parser.class
    end

    it "should handle empty string" do
      parser = Parser.parse("")

      assert_equal "#document-fragment", extract_children(parser).join(",")
      assert_dom_equal "", parser.to_xml
      assert_equal Nokogiri::HTML4::DocumentFragment, parser.class
    end

    it "should handle simple div" do
      parser = Parser.parse("<div></div>")

      assert_equal "#document-fragment,div", extract_children(parser).join(",")
      assert_dom_equal %(<div></div>), parser.to_html
      assert_equal Nokogiri::HTML4::DocumentFragment, parser.class
    end

    it "should handle ERB" do
      parser = Parser.parse("<div><%= some_method %></div>")

      assert_equal "#document-fragment,div,erb,text", extract_children(parser).join(",")
      assert_dom_equal %(<div> <erb loud=""> some_method </erb> </div>), parser.to_xml
      assert_equal Nokogiri::HTML4::DocumentFragment, parser.class
    end

    it "should handle html, head and body" do
      parser = Parser.parse("<html><head><title>Title</title></head><body><h1>Hello</h1></body></html>")

      assert_equal "document,html,html,head,meta,title,text,body,h1,text", extract_children(parser).join(",")
      assert_dom_equal %(<html> <head> <meta http-equiv="Content-Type" content="text/html; charset=UTF-8"> <title>Title</title> </head> <body><h1>Hello</h1></body> </html>), parser.to_xml
      assert_equal Nokogiri::HTML4::Document, parser.class
    end

    it "should handle html and head" do
      parser = Parser.parse("<html><head><title>Title</title></head></html>")

      assert_equal "document,html,html,head,meta,title,text", extract_children(parser).join(",")
      assert_dom_equal %(<html><head> <meta http-equiv="Content-Type" content="text/html; charset=UTF-8"> <title>Title</title> </head></html>), parser.to_xml
      assert_equal Nokogiri::HTML4::Document, parser.class
    end

    it "should handle html and body" do
      parser = Parser.parse("<html><body><h1>Hello</h1></body></html>")

      assert_equal "document,html,html,body,h1,text", extract_children(parser).join(",")
      assert_dom_equal %(<html><body><h1>Hello</h1></body></html>), parser.to_xml
      assert_equal Nokogiri::HTML4::Document, parser.class
    end

    xit "should handle head and body" do
      parser = Parser.parse("<head><title>Title</title></head><body><h1>Hello</h1></body>")

      assert_equal "head,meta,title,text,body,h1,text", extract_children(parser).join(",")
      assert_dom_equal %(<head> <meta http-equiv="Content-Type" content="text/html; charset=UTF-8"> <title>Title</title> </head> <body> <h1>Hello</h1> </body>), parser.to_xml
      assert_equal Nokogiri::HTML4::Document, parser.class
    end

    it "should handle head" do
      parser = Parser.parse("<head><title>Title</title></head>")

      assert_equal "head,title,text", extract_children(parser).join(",")
      assert_dom_equal %(<head> <title>Title</title> </head>), parser.to_xml
      assert_equal Nokogiri::XML::Element, parser.class
    end

    it "should handle body" do
      parser = Parser.parse("<body><h1>Hello</h1></body>")

      assert_equal "body,h1,text", extract_children(parser).join(",")
      assert_dom_equal %(<body> <h1>Hello</h1> </body>), parser.to_xml
      assert_equal Nokogiri::XML::Element, parser.class
    end
  end
end

# frozen_string_literal: true

require_relative "../test_helper"

module Phlexing
  class ParserTest < Minitest::Spec
    before(:each) do
      @nodes = []
    end

    def extract_children(node)
      @nodes << node.name if node.respond_to?(:name)

      if node.is_a?(Nokogiri::XML::NodeSet)
        node.each do |n|
          extract_children(n)
        end
      elsif node&.children
        node.children.each do |node|
          extract_children(node)
        end
      end

      @nodes
    end

    it "should handle nil" do
      parser = Parser.call(nil)

      assert_equal "#document-fragment", extract_children(parser).join(",")
      assert_equal "", parser.to_html
      assert_equal "#document-fragment", parser.name
      assert_equal Nokogiri::HTML5::DocumentFragment, parser.class
    end

    it "should handle empty string" do
      parser = Parser.call("")

      assert_equal "#document-fragment", extract_children(parser).join(",")
      assert_equal "", parser.to_html
      assert_equal "#document-fragment", parser.name
      assert_equal Nokogiri::HTML5::DocumentFragment, parser.class
    end

    it "should handle simple div" do
      parser = Parser.call("<div></div>")

      assert_equal "#document-fragment,div", extract_children(parser).join(",")
      assert_equal %(<div></div>), parser.to_html
      assert_equal "#document-fragment", parser.name
      assert_equal Nokogiri::HTML5::DocumentFragment, parser.class
    end

    it "should handle ERB" do
      parser = Parser.call("<div><%= some_method %></div>")

      assert_equal "#document-fragment,div,erb,text", extract_children(parser).join(",")
      assert_equal %(<div><erb loud=""> some_method </erb></div>), parser.to_html
      assert_equal "#document-fragment", parser.name
      assert_equal Nokogiri::HTML5::DocumentFragment, parser.class
    end

    it "should handle html" do
      parser = Parser.call("<html></html>")

      assert_equal "document,html,head,body", extract_children(parser).join(",")
      assert_equal %(<html></html>), parser.to_html
      assert_equal "document", parser.name
      assert_equal Nokogiri::HTML5::DocumentFragment, parser.class
    end

    it "should handle html, head and body" do
      parser = Parser.call("<html><head><title>Title</title></head><body><h1>Hello</h1></body></html>")

      assert_equal "document,html,head,title,text,body,h1,text", extract_children(parser).join(",")
      assert_equal %(<html><head><title>Title</title></head><body><h1>Hello</h1></body></html>), parser.to_html
      assert_equal "document", parser.name
      assert_equal Nokogiri::HTML5::Document, parser.class
    end

    it "should handle html and head" do
      parser = Parser.call("<html><head><title>Title</title></head></html>")

      assert_equal "document,html,head,title,text,body", extract_children(parser).join(",")
      assert_equal %(<html><head><title>Title</title></head></html>), parser.to_html
      assert_equal "document", parser.name
      assert_equal Nokogiri::HTML5::Document, parser.class
    end

    it "should handle html and body" do
      parser = Parser.call("<html><body><h1>Hello</h1></body></html>")

      assert_equal "document,html,body,h1,text", extract_children(parser).join(",")
      assert_equal %(<html><body><h1>Hello</h1></body></html>), parser.to_html
      assert_equal "document", parser.name
      assert_equal Nokogiri::HTML5::Document, parser.class
    end

    it "should handle head and body" do
      parser = Parser.call("<head><title>Title</title></head><body><h1>Hello</h1></body>")

      assert_equal "head,title,text,body,h1,text", extract_children(parser).join(",")
      assert_equal %(<head><title>Title</title></head><body><h1>Hello</h1></body>), parser.to_html
      assert_equal false, parser.respond_to?(:name)
      assert_equal Nokogiri::XML::NodeSet, parser.class
    end

    it "should handle head with title" do
      parser = Parser.call("<head><title>Title</title></head>")

      assert_equal "head,title,text", extract_children(parser).join(",")
      assert_equal %(<head><title>Title</title></head>), parser.to_html
      assert_equal "head", parser.name
      assert_equal Nokogiri::XML::Element, parser.class
    end

    it "should handle head" do
      parser = Parser.call("<head></head>")

      assert_equal "head", extract_children(parser).join(",")
      assert_equal %(<head><meta http-equiv="Content-Type" content="text/html; charset=UTF-8"></head>), parser.to_html
      assert_equal "head", parser.name
      assert_equal Nokogiri::XML::Element, parser.class
    end

    it "should handle body with h1" do
      parser = Parser.call("<body><h1>Hello</h1></body>")

      assert_equal "body,h1,text", extract_children(parser).join(",")
      assert_equal %(<body><h1>Hello</h1></body>), parser.to_html
      # assert_equal "body", parser.name
      assert_equal Nokogiri::XML::NodeSet, parser.class
    end

    it "should handle body" do
      parser = Parser.call("<body></body>")

      assert_equal "body", extract_children(parser).join(",")
      assert_equal %(<body></body>), parser.to_html
      # assert_equal "body", parser.name
      assert_equal Nokogiri::XML::NodeSet, parser.class
    end
  end
end

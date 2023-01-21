# frozen_string_literal: true

require_relative "../test_helper"

module Phlexing
  class ParserTest < Minitest::Spec
    before(:each) do
      @nodes = []
    end

    def extract_children(node)
      @nodes << node.name

      if node && node.children
        node.children.each do |node|
          extract_children(node)
        end
      end

      @nodes
    end

    xit "should handle nil" do
      parser = Parser.parse(nil)

      assert_equal "document", extract_children(parser).join(",")
      assert_equal Nokogiri::XML::Document, parser.class
    end

    xit "should handle empty tsring" do
      parser = Parser.parse("")

      assert_equal "document", extract_children(parser).join(",")
      assert_equal Nokogiri::XML::Document, parser.class
    end

    xit "should handle simple div" do
      parser = Parser.parse("<div></div>")

      assert_equal Nokogiri::XML::Document, parser.class
    end

    xit "should handle simple html with head and body" do
      parser = Parser.parse("<html><head><title>Title</title><body><h1>Hello</h1></body></html>")

      assert_equal "document,html,html,head,meta,title,text,body,h1,text", extract_children(parser).join(",")
      assert_equal Nokogiri::XML::Document, parser.class
    end

    xit "should handle ERB" do
      parser = Parser.parse("<div><%= some_method %></div>")

      assert_equal "document,div,erb,text", extract_children(parser).join(",")
      assert_equal Nokogiri::XML::Document, parser.class
    end
  end
end

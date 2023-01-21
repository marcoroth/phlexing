# frozen_string_literal: true

require "syntax_tree"
require "erb_parser"

module Phlexing
  class RubyAnalyzer
    extend Forwardable

    attr_accessor :ivars, :locals, :idents

    def self.analyze(source)
      new.analyze(source)
    end

    def initialize
      @ivars = Set.new
      @locals = Set.new
      @idents = Set.new
      @visitor = Visitor.new(self)
    end

    def analyze(source)
      source = source.to_s
      ruby = extract_ruby_from_erb(source)
      program = SyntaxTree.parse(ruby)
      @visitor.visit(program)

      self
    rescue SyntaxTree::Parser::ParseError
      self
    end

    def extract_ruby_from_erb(source)
      tokens = ErbParser.parse(source).tokens
      lines = tokens.map { |tag| tag.is_a?(ErbParser::ErbTag) && !tag.to_s.start_with?("<%#") ? tag.ruby_code.delete_prefix("=") : nil }

      lines.join("\n")
    rescue ErbParser::TreetopRunner::ParseError
      ""
    end
  end
end

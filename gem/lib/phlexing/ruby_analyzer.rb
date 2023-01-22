# frozen_string_literal: true

require "syntax_tree"

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
      document = Parser.parse(source)
      nodes = document.css("erb")

      lines = nodes.map { |node| node.text.to_s.strip }
      lines = lines.map { |line| line.delete_prefix("=") }
      lines = lines.map { |line| line.delete_prefix("-") }
      lines = lines.map { |line| line.delete_suffix("-") }

      lines.join("\n")
    rescue StandardError
      ""
    end
  end
end

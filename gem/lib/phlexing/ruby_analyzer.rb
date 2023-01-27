# frozen_string_literal: true

require "syntax_tree"

module Phlexing
  class RubyAnalyzer
    attr_accessor :ivars, :locals, :idents, :calls, :consts, :instance_methods

    def self.call(source)
      new.analyze(source)
    end

    def initialize
      @ivars = Set.new
      @locals = Set.new
      @idents = Set.new
      @calls = Set.new
      @consts = Set.new
      @instance_methods = Set.new
      @visitor = Visitor.new(self)
    end

    def analyze(source)
      code = extract_ruby_from_erb(source.to_s)

      analyze_ruby(code)
    end

    def analyze_ruby(code)
      program = SyntaxTree.parse(code)
      @visitor.visit(program)

      self
    rescue SyntaxTree::Parser::ParseError, NoMethodError
      self
    end

    private

    def extract_ruby_from_erb(source)
      document = Parser.call(source)
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

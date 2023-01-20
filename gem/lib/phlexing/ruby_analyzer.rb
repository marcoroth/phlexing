# frozen_string_literal: true

require "syntax_tree"
require "erb_parser"

module Phlexing
  class RubyAnalyzer
    extend Forwardable

    attr_accessor :ivars, :locals, :idents

    def self.analyze(html)
      new.analyze(html)
    end

    def initialize
      @ivars = Set.new
      @locals = Set.new
      @idents = Set.new
      @visitor = Visitor.new(self)
    end

    def analyze(html)
      ruby = extract_ruby_from_erb(html)
      program = SyntaxTree.parse(ruby)
      @visitor.visit(program)

      self
    rescue StandardError => e
      puts e.inspect
    end

    def extract_ruby_from_erb(html)
      tokens = ErbParser.parse(html).tokens
      lines = tokens.map { |tag| tag.is_a?(ErbParser::ErbTag) && !tag.to_s.start_with?("<%#") ? tag.ruby_code.delete_prefix("=") : nil }

      lines.join("\n")
    rescue StandardError
      ""
    end
  end
end

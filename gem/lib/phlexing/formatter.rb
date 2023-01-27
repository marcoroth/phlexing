# frozen_string_literal: true

require "syntax_tree"

module Phlexing
  class Formatter
    def self.call(...)
      new(...).call
    end

    def initialize(source, max: 80)
      @source = source.to_s.dup
      @max = max
    end

    def call
      SyntaxTree.format(@source, @max).strip
    rescue SyntaxTree::Parser::ParseError, NoMethodError
      @source
    end
  end
end

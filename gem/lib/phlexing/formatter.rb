# frozen_string_literal: true

require "syntax_tree"

module Phlexing
  class Formatter
    def self.format(source, max: 80)
      SyntaxTree.format(source.to_s, max).strip
    rescue SyntaxTree::Parser::ParseError
      source
    end
  end
end

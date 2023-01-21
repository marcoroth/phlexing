# frozen_string_literal: true

require "syntax_tree"

module Phlexing
  class Formatter
    def self.format(code, max: 80)
      SyntaxTree.format(code, max).strip
    rescue SyntaxTree::Parser::ParseError
      code
    end
  end
end

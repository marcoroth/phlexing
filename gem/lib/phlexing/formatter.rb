# frozen_string_literal: true

require "syntax_tree"

module Phlexing
  class Formatter
    def self.format(code)
      SyntaxTree.format(code).strip
    rescue SyntaxTree::Parser::ParseError
      code
    end
  end
end

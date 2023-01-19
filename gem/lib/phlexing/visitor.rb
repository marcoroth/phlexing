# frozen_string_literal: true

require "syntax_tree"

module Phlexing
  class Visitor < SyntaxTree::Visitor
    def initialize(converter)
      @converter = converter
    end

    def visit_ivar(node)
      @converter.ivars << node.value.from(1)
    end

    def visit_vcall(node)
      @converter.locals << node.value.value
    end

    def visit_ident(node)
      @converter.idents << node.value
    end
  end
end

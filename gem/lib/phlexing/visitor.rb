# frozen_string_literal: true

require "syntax_tree"

module Phlexing
  class Visitor < SyntaxTree::Visitor
    using Refinements::StringRefinements

    def initialize(converter)
      @converter = converter
    end

    def visit_ivar(node)
      @converter.ivars << node.value.from(1)
    end

    def visit_const(node)
      @converter.consts << node.value
    end

    def visit_command(node)
      @converter.instance_methods << node.message.value
      super
    end

    def visit_call(node)
      if node.receiver
        case node.receiver
        when SyntaxTree::VarRef
          value = node.receiver.value.value

          case node.receiver.value
          when SyntaxTree::IVar
            @converter.ivars << value.from(1)
          when SyntaxTree::Ident
            @converter.idents << value
          end

          @converter.calls << value

        when SyntaxTree::VCall
          case node.receiver.value
          when SyntaxTree::Ident
            @converter.calls << node.receiver.value.value
          end

        when SyntaxTree::Ident
          value = node.receiver.value.value.value

          @converter.idents << value unless value.ends_with?("?")
          @converter.calls << value

        when SyntaxTree::Const
          @converter.calls << node.receiver.value
        end

      elsif node.receiver.nil? && node.operator.nil?
        case node.message
        when SyntaxTree::Ident
          if node.message.value.end_with?("?") || node.child_nodes[3].is_a?(SyntaxTree::ArgParen)
            @converter.instance_methods << node.message.value
            @converter.calls << node.message.value
          else
            @converter.idents << node.message.value
          end
        end
      end

      super
    end

    def visit_vcall(node)
      @converter.locals << node.value.value
    end

    def visit_ident(node)
      @converter.idents << node.value
    end
  end
end

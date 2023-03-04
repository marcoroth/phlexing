# frozen_string_literal: true

require "syntax_tree"

module Phlexing
  class Visitor < SyntaxTree::Visitor
    using Refinements::StringRefinements
    include Helpers

    def initialize(analyzer)
      @analyzer = analyzer
    end

    def visit_ivar(node)
      @analyzer.ivars << node.value.from(1)
    end

    def visit_const(node)
      @analyzer.consts << node.value
    end

    def visit_command(node)
      if !rails_helper?(node.message.value)
        @analyzer.instance_methods << node.message.value
      end
      super
    end

    def visit_call(node)
      if node.receiver
        case node.receiver
        when SyntaxTree::VarRef
          value = node.receiver.value.value

          case node.receiver.value
          when SyntaxTree::IVar
            @analyzer.ivars << value.from(1)
          when SyntaxTree::Ident
            @analyzer.idents << value
          end

          @analyzer.calls << value

        when SyntaxTree::VCall
          case node.receiver.value
          when SyntaxTree::Ident
            @analyzer.calls << node.receiver.value.value
          end

        when SyntaxTree::Ident
          value = node.receiver.value.value.value

          @analyzer.idents << value unless value.ends_with?("?")
          @analyzer.calls << value

        when SyntaxTree::Const
          @analyzer.calls << node.receiver.value
        end

      elsif node.receiver.nil? && node.operator.nil?
        case node.message
        when SyntaxTree::Ident
          if node.message.value.end_with?("?") || node.child_nodes[3].is_a?(SyntaxTree::ArgParen)
            if !rails_helper?(node.message.value)
              @analyzer.instance_methods << node.message.value
              @analyzer.calls << node.message.value
            end
          else
            @analyzer.idents << node.message.value
          end
        end
      end

      super
    end

    def visit_vcall(node)
      if !rails_helper?(node.value.value)
        @analyzer.locals << node.value.value
      end
    end

    def visit_ident(node)
      if !rails_helper?(node.value)
        @analyzer.idents << node.value
      end
    end

    private

    def rails_helper?(name)
      if known_rails_helpers.keys.include?(name)
        @analyzer.includes << known_rails_helpers[name]
        return true
      end

      if routes_helpers.map { |regex| name.scan(regex).any? }.reduce(:|)
        @analyzer.includes << "Phlex::Rails::Helpers::Routes"
        return true
      end

      false
    end
  end
end

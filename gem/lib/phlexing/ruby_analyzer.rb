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
      lines = []

      lines << ruby_lines_from_erb_tags(document)
      lines << ruby_lines_from_erb_attributes(document)

      lines.join("\n")
    rescue StandardError
      ""
    end

    def ruby_lines_from_erb_tags(document)
      nodes = document.css("erb")

      nodes
        .map { |node| node.text.to_s.strip }
        .map { |line| line.delete_prefix("=") }
        .map { |line| line.delete_prefix("-") }
        .map { |line| line.delete_suffix("-") }
    end

    def ruby_lines_from_erb_attributes(document)
      attributes = document.css("*").map(&:attributes)

      lines = []

      attributes.each do |pair|
        pair.select! { |name, _| name.start_with?("data-erb-") }

        pair.each do |_, value|
          Parser
            .call(value)
            .children
            .select { |child| child.is_a?(Nokogiri::XML::Node) }
            .each   { |child| lines << child.text.strip }
        end
      end

      lines
    end
  end
end

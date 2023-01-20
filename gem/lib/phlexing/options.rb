# frozen_string_literal: true

module Phlexing
  class Options
    attr_accessor :component, :component_name, :parent_component, :whitespace

    alias_method :whitespace?, :whitespace
    alias_method :component?, :component

    def initialize(component: false, component_name: "Component", parent_component: "Phlex::HTML", whitespace: true)
      @component = component
      @component_name = safe_constant_name(component_name)
      @parent_component = safe_constant_name(parent_component)
      @whitespace = whitespace
    end

    def safe_constant_name(name)
      name = name.to_s

      if name[0] == "0" || name[0].to_i != 0
        "A#{name}"
      else
        name
      end
    end
  end
end

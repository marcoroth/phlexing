# frozen_string_literal: true

require_relative "phlexing/version"
require_relative "phlexing/refinements/string_refinements"
require_relative "phlexing/patches/html_press"

require_relative "phlexing/erb_transformer"
require_relative "phlexing/formatter"
require_relative "phlexing/helpers"
require_relative "phlexing/minifier"
require_relative "phlexing/options"
require_relative "phlexing/parser"
require_relative "phlexing/ruby_analyzer"
require_relative "phlexing/visitor"

require_relative "phlexing/name_suggestor"
require_relative "phlexing/component_generator"
require_relative "phlexing/template_generator"
require_relative "phlexing/converter"

module Phlexing
end

# frozen_string_literal: true

require_relative "lib/phlexing/version"

Gem::Specification.new do |spec|
  spec.name = "phlexing"
  spec.version = Phlexing::VERSION
  spec.authors = ["Marco Roth"]
  spec.email = ["marco.roth@hey.com"]

  spec.summary = "Simple ERB to Phlex converter"
  spec.description = "Simple ERB to Phlex converter"
  spec.homepage = "https://github.com/marcoroth/phlexing"
  spec.license = "MIT"
  spec.required_ruby_version = ">= 3.0.0"

  spec.metadata["homepage_uri"] = spec.homepage
  spec.metadata["source_code_uri"] = "https://github.com/marcoroth/phlexing"
  spec.metadata["changelog_uri"] = "https://github.com/marcoroth/phlexing"
  spec.metadata["rubygems_mfa_required"] = "true"

  spec.files = Dir.chdir(__dir__) do
    `git ls-files -z`.split("\x0").reject do |f|
      (f == __FILE__) || f.match(%r{\A(?:(?:bin|test|spec|features)/|\.(?:git|travis|circleci)|appveyor)})
    end
  end

  spec.bindir = "exe"
  spec.executables = spec.files.grep(%r{\Aexe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]

  spec.add_dependency "deface", "~> 1.9"
  spec.add_dependency "html_press", "~> 0.8.2"
  spec.add_dependency "nokogiri", "~> 1.0"
  spec.add_dependency "phlex", "~> 1.6"
  spec.add_dependency "phlex-rails", ">= 0.9", "< 2.0"
  spec.add_dependency "slim"
  spec.add_dependency "syntax_tree", "~> 6.0"
end

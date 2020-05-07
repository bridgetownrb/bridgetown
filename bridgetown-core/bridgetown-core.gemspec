# frozen_string_literal: true

require_relative "lib/bridgetown-core/version"

Gem::Specification.new do |s|
  s.name          = "bridgetown-core"
  s.version       = Bridgetown::VERSION
  s.license       = "MIT"
  s.author        = "Bridgetown Team"
  s.email         = "maintainers@bridgetownrb.com"
  s.homepage      = "https://www.bridgetownrb.com"
  s.summary       = "A Webpack-aware, Ruby-based static site generator for the modern Jamstack era"
  s.description   = "Bridgetown is a Webpack-aware, Ruby-powered static site generator for the modern Jamstack era"

  s.files         = `git ls-files -z`.split("\x0").reject do |f|
    f.match(%r!^(benchmark|features|script|test)/!)
  end
  s.executables   = ["bridgetown"]
  s.bindir        = "bin"
  s.require_paths = ["lib"]

  s.metadata      = {
    "source_code_uri" => "https://github.com/bridgetownrb/bridgetown",
    "bug_tracker_uri" => "https://github.com/bridgetownrb/bridgetown/issues",
    "changelog_uri"   => "https://github.com/bridgetownrb/bridgetown/releases",
    "homepage_uri"    => s.homepage,
  }

  s.rdoc_options = ["--charset=UTF-8"]

  s.required_ruby_version     = ">= 2.5.0"
  s.required_rubygems_version = ">= 2.7.0"

  s.add_runtime_dependency("activesupport",         "~> 6.0")
  s.add_runtime_dependency("addressable",           "~> 2.4")
  s.add_runtime_dependency("colorator",             "~> 1.0")
  s.add_runtime_dependency("faraday",               "~> 1.0")
  s.add_runtime_dependency("i18n",                  "~> 1.0")
  s.add_runtime_dependency("kramdown",              "~> 2.1")
  s.add_runtime_dependency("kramdown-parser-gfm",   "~> 1.0")
  s.add_runtime_dependency("liquid",                "~> 4.0")
  s.add_runtime_dependency("listen",                "~> 3.0")
  s.add_runtime_dependency("mercenary",             "~> 0.4.0")
  s.add_runtime_dependency("pathutil",              "~> 0.9")
  s.add_runtime_dependency("rouge",                 "~> 3.0")
  s.add_runtime_dependency("safe_yaml",             "~> 1.0")
  s.add_runtime_dependency("terminal-table",        "~> 1.8")
end

# frozen_string_literal: true

require_relative "lib/bridgetown/version"

Gem::Specification.new do |s|
  s.name          = "bridgetown"
  s.version       = Bridgetown::VERSION
  s.license       = "MIT"
  s.authors       = ["Tom Preston-Werner", "Parker Moore", "Matt Rogers", "Jared White"]
  s.email         = ["maintainers@bridgetownrb.com"]
  s.homepage      = "https://bridgetownrb.com"
  s.summary       = "A Webpack-aware, Ruby-based static site generator for the modern JAMstack era"
  s.description   = "Bridgetown is a Webpack-aware, Ruby-based static site generator for the modern JAMstack era"

  all_files       = `git ls-files -z`.split("\x0")
  s.files         = all_files.grep(%r!^(exe|lib|rubocop)/|^.rubocop.yml$!)
  s.executables   = ["bridgetown"]
  s.bindir        = "exe"
  s.require_paths = ["lib"]

  s.metadata      = {
    "source_code_uri" => "https://github.com/bridgetownrb/bridgetown",
    "bug_tracker_uri" => "https://github.com/bridgetownrb/bridgetown/issues",
    "changelog_uri"   => "https://github.com/bridgetownrb/bridgetown/releases",
    "homepage_uri"    => s.homepage,
  }

  s.rdoc_options     = ["--charset=UTF-8"]
  s.extra_rdoc_files = %w(README.markdown LICENSE)

  s.required_ruby_version     = ">= 2.4.0"
  s.required_rubygems_version = ">= 2.7.0"

  s.add_runtime_dependency("addressable",           "~> 2.4")
  s.add_runtime_dependency("colorator",             "~> 1.0")
  s.add_runtime_dependency("em-websocket",          "~> 0.5")
  s.add_runtime_dependency("i18n",                  "~> 1.0")
  s.add_runtime_dependency("jekyll-watch",          "~> 2.0")
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

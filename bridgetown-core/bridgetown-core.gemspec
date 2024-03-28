# frozen_string_literal: true

require_relative "lib/bridgetown-core/version"

Gem::Specification.new do |s|
  s.name          = "bridgetown-core"
  s.version       = Bridgetown::VERSION
  s.license       = "MIT"
  s.author        = "Bridgetown Team"
  s.email         = "maintainers@bridgetownrb.com"
  s.homepage      = "https://www.bridgetownrb.com"
  s.summary       = "A next-generation, progressive site generator & fullstack framework, powered by Ruby"
  s.description   = "Bridgetown is a next-generation, progressive site generator & fullstack framework, powered by Ruby"

  s.files         = `git ls-files -z`.split("\x0").reject do |f|
    f.match(%r!^(benchmark|features|script|test)/!)
  end
  s.executables   = ["bridgetown"]
  s.bindir        = "bin"
  s.require_paths = ["lib"]

  s.metadata      = {
    "source_code_uri"       => "https://github.com/bridgetownrb/bridgetown",
    "bug_tracker_uri"       => "https://github.com/bridgetownrb/bridgetown/issues",
    "changelog_uri"         => "https://github.com/bridgetownrb/bridgetown/releases",
    "homepage_uri"          => s.homepage,
    "rubygems_mfa_required" => "true",
  }

  s.rdoc_options = ["--charset=UTF-8"]

  s.required_ruby_version     = ">= 3.1.0"

  s.add_runtime_dependency("activemodel",               [">= 6.0", "< 8.0"])
  s.add_runtime_dependency("activesupport",             [">= 6.0", "< 8.0"])
  s.add_runtime_dependency("addressable",               "~> 2.4")
  s.add_runtime_dependency("amazing_print",             "~> 1.2")
  s.add_runtime_dependency("colorator",                 "~> 1.0")
  s.add_runtime_dependency("csv",                       "~> 3.2")
  s.add_runtime_dependency("erubi",                     "~> 1.9")
  s.add_runtime_dependency("faraday",                   "~> 2.0")
  s.add_runtime_dependency("faraday-follow_redirects",  "~> 0.3")
  s.add_runtime_dependency("hash_with_dot_access",      "~> 1.2")
  s.add_runtime_dependency("i18n",                      "~> 1.0")
  s.add_runtime_dependency("kramdown",                  "~> 2.1")
  s.add_runtime_dependency("kramdown-parser-gfm",       "~> 1.0")
  s.add_runtime_dependency("liquid",                    [">= 5.0", "< 5.5"])
  s.add_runtime_dependency("listen",                    "~> 3.0")
  s.add_runtime_dependency("rack",                      ">= 3.0")
  s.add_runtime_dependency("rake",                      ">= 13.0")
  s.add_runtime_dependency("roda",                      "~> 3.46")
  s.add_runtime_dependency("rouge",                     [">= 3.0", "< 5.0"])
  s.add_runtime_dependency("serbea",                    "~> 1.0")
  s.add_runtime_dependency("thor",                      "~> 1.1")
  s.add_runtime_dependency("tilt",                      "~> 2.0")
  s.add_runtime_dependency("zeitwerk",                  "~> 2.5")
end

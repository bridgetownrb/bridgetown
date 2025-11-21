# frozen_string_literal: true

require_relative "../bridgetown-foundation/lib/bridgetown/version"

Gem::Specification.new do |spec|
  spec.name          = "bridgetown-core"
  spec.version       = Bridgetown::VERSION
  spec.license       = "MIT"
  spec.author        = "Bridgetown Team"
  spec.email         = "maintainers@bridgetownrb.com"
  spec.homepage      = "https://www.bridgetownrb.com"
  spec.summary       = "A next-generation, progressive site generator & fullstack framework, powered by Ruby"
  spec.description   = "Bridgetown is a next-generation, progressive site generator & fullstack framework, powered by Ruby"

  spec.files         = `git ls-files -z`.split("\x0").reject do |f|
    f.match(%r!^(benchmark|features|script|test)/!)
  end
  spec.executables   = ["bridgetown", "bt"] # `bt` is a shortcut to `bridgetown` command
  spec.bindir        = "bin"
  spec.require_paths = ["lib"]

  spec.metadata      = {
    "source_code_uri"       => "https://github.com/bridgetownrb/bridgetown",
    "bug_tracker_uri"       => "https://github.com/bridgetownrb/bridgetown/issues",
    "changelog_uri"         => "https://github.com/bridgetownrb/bridgetown/releases",
    "homepage_uri"          => spec.homepage,
    "rubygems_mfa_required" => "true",
  }

  spec.rdoc_options = ["--charset=UTF-8"]

  spec.required_ruby_version     = ">= 3.2.0"

  spec.add_dependency("addressable",               "~> 2.4")
  spec.add_dependency("amazing_print",             "~> 1.2")
  spec.add_dependency("base64",                    ">= 0.3")
  spec.add_dependency("bigdecimal",                ">= 3.2")
  spec.add_dependency("bridgetown-foundation",     Bridgetown::VERSION)
  spec.add_dependency("csv",                       "~> 3.2")
  spec.add_dependency("erubi",                     "~> 1.9")
  spec.add_dependency("faraday",                   "~> 2.0")
  spec.add_dependency("faraday-follow_redirects",  "~> 0.3")
  spec.add_dependency("freyia",                    ">= 0.5")
  spec.add_dependency("i18n",                      "~> 1.0")
  spec.add_dependency("irb",                       ">= 1.14")
  spec.add_dependency("kramdown",                  "~> 2.1")
  spec.add_dependency("kramdown-parser-gfm",       "~> 1.0")
  spec.add_dependency("liquid",                    [">= 5.0", "< 5.5"])
  spec.add_dependency("listen",                    "~> 3.0")
  spec.add_dependency("rack",                      ">= 3.0")
  spec.add_dependency("rackup",                    "~> 2.0")
  spec.add_dependency("rake",                      ">= 13.0")
  spec.add_dependency("roda",                      "~> 3.46")
  spec.add_dependency("rouge",                     [">= 3.0", "< 5.0"])
  spec.add_dependency("samovar",                   ">= 2.4")
  spec.add_dependency("securerandom",              "~> 0.4")
  spec.add_dependency("serbea",                    ">= 2.4.1")
  spec.add_dependency("signalize",                 "~> 1.3")
  spec.add_dependency("streamlined",               ">= 0.6.0")
  spec.add_dependency("thor",                      "~> 1.1")
  spec.add_dependency("tilt",                      "~> 2.0")
  spec.add_dependency("zeitwerk",                  ">= 2.7.3")
end

# frozen_string_literal: true

require_relative "lib/bridgetown/version"

Gem::Specification.new do |spec|
  spec.name          = "bridgetown-foundation"
  spec.version       = Bridgetown::VERSION
  spec.author        = "Bridgetown Team"
  spec.email         = "maintainers@bridgetownrb.com"
  spec.summary       = "Ruby language extensions and other utilities useful for the Bridgetown ecosystem"
  spec.homepage      = "https://github.com/bridgetownrb/bridgetown/tree/main/bridgetown-foundation"
  spec.license       = "MIT"
  spec.required_ruby_version = ">= 3.2"

  spec.files         = `git ls-files -z`.split("\x0").reject { |f| f.match(%r!^(test|script)/!) }
  spec.require_paths = ["lib"]

  spec.metadata      = {
    "source_code_uri"       => "https://github.com/bridgetownrb/bridgetown",
    "bug_tracker_uri"       => "https://github.com/bridgetownrb/bridgetown/issues",
    "changelog_uri"         => "https://github.com/bridgetownrb/bridgetown/releases",
    "homepage_uri"          => spec.homepage,
    "rubygems_mfa_required" => "true",
  }

  spec.add_dependency("hash_with_dot_access", "~> 2.0")
  spec.add_dependency("inclusive", "~> 1.0")
  spec.add_dependency("zeitwerk", "~> 2.5")
end

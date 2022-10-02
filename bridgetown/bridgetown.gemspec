# frozen_string_literal: true

require_relative "../bridgetown-core/lib/bridgetown-core/version"

Gem::Specification.new do |s|
  s.name          = "bridgetown"
  s.version       = Bridgetown::VERSION
  s.license       = "MIT"
  s.author        = "Bridgetown Team"
  s.email         = "maintainers@bridgetownrb.com"
  s.homepage      = "https://www.bridgetownrb.com"
  s.summary       = "A next-generation, progressive site generator & fullstack framework, powered by Ruby"
  s.description   = "Bridgetown is a next-generation, progressive site generator & fullstack framework, powered by Ruby"

  s.files        = `git ls-files -z`.split("\0")
  s.require_path = "lib"

  s.metadata      = {
    "source_code_uri" => "https://github.com/bridgetownrb/bridgetown",
    "bug_tracker_uri" => "https://github.com/bridgetownrb/bridgetown/issues",
    "changelog_uri"   => "https://github.com/bridgetownrb/bridgetown/releases",
    "homepage_uri"    => s.homepage,
  }

  s.required_ruby_version     = ">= 2.7.0"

  s.add_dependency("bridgetown-builder", Bridgetown::VERSION)
  s.add_dependency("bridgetown-core", Bridgetown::VERSION)
  s.add_dependency("bridgetown-paginate", Bridgetown::VERSION)
  s.metadata["rubygems_mfa_required"] = "true"
end

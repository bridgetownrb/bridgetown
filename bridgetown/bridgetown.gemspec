# frozen_string_literal: true

require_relative "../bridgetown-core/lib/bridgetown-core/version"

Gem::Specification.new do |s|
  s.name          = "bridgetown"
  s.version       = Bridgetown::VERSION
  s.license       = "MIT"
  s.author        = "Bridgetown Team"
  s.email         = "maintainers@bridgetownrb.com"
  s.homepage      = "https://bridgetownrb.com"
  s.summary       = "A Webpack-aware, Ruby-based static site generator for the modern JAMstack era"
  s.description   = "Bridgetown is a Webpack-aware, Ruby-based static site generator for the modern JAMstack era"

  s.files        = `git ls-files -z`.split("\0")
  s.test_files   = `git ls-files -z -- {fixtures,features}/*`.split("\0")
  s.require_path = "lib"

  s.required_ruby_version     = ">= 2.4.0"
  s.required_rubygems_version = ">= 2.7.0"

  s.add_dependency("bridgetown-core", Bridgetown::VERSION)
end

# frozen_string_literal: true

require_relative "../bridgetown-core/lib/bridgetown-core/version"

Gem::Specification.new do |spec|
  spec.name          = "bridgetown-routes"
  spec.version       = Bridgetown::VERSION
  spec.author        = "Bridgetown Team"
  spec.email         = "maintainers@bridgetownrb.com"
  spec.summary       = "A Bridgetown plugin to add support for file-based Roda backend routes within the source folder."
  spec.homepage      = "https://github.com/bridgetownrb/bridgetown/tree/main/bridgetown-routes"
  spec.license       = "MIT"

  spec.files         = `git ls-files -z`.split("\x0").reject { |f| f.match(%r!^(test|script|spec|features)/!) }
  spec.require_paths = ["lib"]

  spec.add_dependency("bridgetown-core", Bridgetown::VERSION)
end


lib = File.expand_path("../lib", __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require "bridgetown/version"

Gem::Specification.new do |spec|
  spec.name          = "bridgetown"
  spec.version       = Bridgetown::VERSION
  spec.authors       = ["Jared White"]
  spec.email         = ["maintainers@bridgetownrb.com"]

  spec.summary       = %q{A Webpack-aware, Ruby-based static site generator for the modern JAMstack era}
  spec.description   = %q{Bridgetown is a Webpack-aware, Ruby-based static site generator for the modern JAMstack era}
  spec.homepage      = "https://bridgetownrb.com"
  spec.license       = "MIT"

  # Specify which files should be added to the gem when it is released.
  # The `git ls-files -z` loads the files in the RubyGem that have been added into git.
  spec.files         = Dir.chdir(File.expand_path('..', __FILE__)) do
    `git ls-files -z`.split("\x0").reject { |f| f.match(%r{^(test|spec|features)/}) }
  end
  spec.bindir        = "exe"
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]

  spec.add_development_dependency "bundler", "~> 1.17"
  spec.add_development_dependency "rake", "~> 10.0"
end

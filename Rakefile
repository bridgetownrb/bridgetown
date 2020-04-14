# frozen_string_literal: true

task default: %w[test_all]

desc "Test all Bridgetown gems in monorepo"
task :test_all do
  sh "cd bridgetown-core && script/cibuild"
end

desc "Build and release all Bridgetown gems in monorepo"
task release_all: %w[test_all] do
  sh "cd bridgetown && bundle exec rake release"
  sh "cd bridgetown-core && bundle exec rake release"
  sh "cd .."
end

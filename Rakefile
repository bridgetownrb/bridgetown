# frozen_string_literal: true

task default: %w(test_all)

desc "Test all Bridgetown gems in monorepo"
task :test_all do
  sh "cd bridgetown-core && script/cibuild"
  sh "cd bridgetown-builder && script/cibuild"
  sh "cd bridgetown-paginate && script/cibuild"
  sh "cd bridgetown-routes && script/cibuild"
end

task :release_all_unsafe do
  sh "cd bridgetown-core && bundle exec rake release"
  sh "cd bridgetown-builder && bundle exec rake release"
  sh "cd bridgetown-paginate && bundle exec rake release"
  sh "cd bridgetown-routes && bundle exec rake release"
  sh "cd bridgetown && bundle exec rake release"
end

desc "Build and release all Bridgetown gems in monorepo"
task release_all: %w(test_all release_all_unsafe)

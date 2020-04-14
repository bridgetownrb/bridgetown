# frozen_string_literal: true

desc "Build and release all Bridgetown gems in monorepo"
task :release_all do
  sh "cd bridgetown && bundle exec rake release"
  sh "cd bridgetown-core && bundle exec rake release"
  sh "cd .."
end

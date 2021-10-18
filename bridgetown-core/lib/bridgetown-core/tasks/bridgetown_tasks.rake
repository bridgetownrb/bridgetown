# frozen_string_literal: true

desc "Generate a secret key for use in sessions, token generation, and beyond"
task :secret do
  require "securerandom"
  puts SecureRandom.hex(64) # rubocop:disable Bridgetown/NoPutsAllowed
end

namespace :frontend do
  desc "Run frontend bundler independently"
  task :watcher, :sidecar do |_task, args|
    # sidecar is when the task is running alongside the start command
    sidecar = args[:sidecar] == true
    Bridgetown::Utils::Aux.group do
      run_process "Frontend", :yellow, "bundle exec bridgetown frontend:dev"
    end
    if sidecar
      sleep 4 # give Webpack time to boot before returning control to the start command
    else
      trap("INT") do
        Bridgetown::Utils::Aux.kill_processes
        sleep 0.5
        exit(0)
      end
      loop { sleep 1000 }
    end
  end
end

desc "Prerequisite task which loads site and provides automation"
task :environment do
  class HammerActions < Thor # rubocop:disable Lint/ConstantDefinitionInBlock
    include Thor::Actions
    include Bridgetown::Commands::Actions

    def self.source_root
      Dir.pwd
    end

    def self.exit_on_failure?
      true
    end

    private

    def site
      @site ||= Bridgetown::Site.new(Bridgetown.configuration)
    end
  end

  define_singleton_method :automation do |*args, &block|
    @hammer ||= HammerActions.new
    @hammer.instance_exec(*args, &block)
  end

  define_singleton_method :site do
    @hammer ||= HammerActions.new
    @hammer.send(:site)
  end
end

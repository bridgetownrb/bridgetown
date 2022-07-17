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
      # give FE bundler time to boot before returning control to the start command
      sleep Bridgetown::Utils.frontend_bundler_type == :esbuild ? 3 : 4
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
task :environment do # rubocop:todo Metrics/BlockLength
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

    def site(context: :static)
      @site ||= begin
        config = Bridgetown.configuration
        config.run_initializers! context: context
        Bridgetown::Site.new(config)
      end
    end
  end

  define_singleton_method :automation do |*args, &block|
    @hammer ||= HammerActions.new
    @hammer.instance_exec(*args, &block)
  end

  define_singleton_method :site do |**kwargs|
    @hammer ||= HammerActions.new
    @hammer.send(:site, **kwargs)
  end
end

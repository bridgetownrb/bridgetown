# frozen_string_literal: true

desc "Start the Puma server and Bridgetown watcher"
task :start do
  ARGV.reject! { |arg| arg == "start" }
  if ARGV.include?("--help") || ARGV.include?("-h")
    Bridgetown::Commands::Build.start(ARGV)
    puts "  Using watch mode"
    next
  end

  if Bundler.definition.specs.find { |s| s.name == "puma" }
    Bridgetown.logger.writer.enable_prefix
    Bridgetown.logger.info "Starting:", "Bridgetown v#{Bridgetown::VERSION.magenta}" \
                           " (codename \"#{Bridgetown::CODE_NAME.yellow}\")"
    sleep 0.5

    Process.fork do
      require "puma/cli"

      cli = Puma::CLI.new []
      cli.run
    end

    sleep 4
    Bridgetown::Commands::Build.start(["-w"] + ARGV)

    sleep 0.5 # let Puma finish cleaning up
  else
    puts "** No Rack-compatible server found, falling back on Webrick **"
    Bridgetown::Commands::Serve.start(ARGV)
  end
end

desc "Alias of start"
task dev: :start

desc "Prerequisite task which loads site and provides automation"
task :environment do
  class HammerActions < Thor
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
    @hammer.site
  end
end

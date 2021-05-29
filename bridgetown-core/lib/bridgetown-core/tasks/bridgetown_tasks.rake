# frozen_string_literal: true

desc "Start the Puma server and Bridgetown watcher"
task :start do
  ARGV.reject! { |arg| arg == "start" }
  if ARGV.include?("--help") || ARGV.include?("-h")
    Bridgetown::Commands::Build.start(ARGV)
    puts "  Using watch mode"
    next
  end

  Bridgetown.logger.writer.enable_prefix
  Bridgetown.logger.info "Starting:", "Bridgetown v#{Bridgetown::VERSION.magenta}" \
                         " (codename \"#{Bridgetown::CODE_NAME.yellow}\")"
  sleep 0.5

  rackpid =
    Process.fork do
      if Bundler.definition.specs.find { |s| s.name == "puma" }
        require "puma/cli"

        cli = Puma::CLI.new []
        cli.run
      else
        puts "** No Rack-compatible server found, falling back on Webrick **"
        Bridgetown::Commands::Serve.start(["-P", "4001", "--quiet", "--no-watch", "--skip-initial-build"])
      end
    end

  Rake::Task["frontend:servers"].invoke(true) unless Bridgetown.env.production?

  begin
    # TODO: set the site's url value in the config to localhost, etc.
    Bridgetown::Commands::Build.start(["-w"] + ARGV)
  rescue StandardError => e
    Process.kill "SIGINT", rackpid
    sleep 0.5
    raise e
  ensure
    Bridgetown::Utils::Aux.kill_processes
  end

  sleep 0.5 # finish cleaning up
end

desc "Alias of start"
task dev: :start

namespace :frontend do
  desc "Run frontend bundler and live reload server independently"
  task :servers, :sidecar do |_task, args|
    sidecar = args[:sidecar] == true
    Bridgetown::Utils::Aux.group do
      run_process "Frontend", :yellow, "bundle exec bridgetown frontend:dev"
      run_process "Live", nil, "#{"sleep 7 &&" if sidecar} yarn sync --color"
    end
    if sidecar
      sleep 4 # give Webpack time to boot
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

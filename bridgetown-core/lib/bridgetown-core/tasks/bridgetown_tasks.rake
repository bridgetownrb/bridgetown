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

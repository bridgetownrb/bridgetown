# frozen_string_literal: true

desc "Generate a secret key for use in sessions, token generation, and beyond"
task :secret do
  require "securerandom"
  puts SecureRandom.hex(64) # rubocop:disable Bridgetown/NoPutsAllowed
end

namespace :roda do
  desc "Prints out the Roda routes file"
  task :routes do
    require "bridgetown-core/rack/boot"

    Bridgetown::Rack::Routes.print_routes
  end
end

desc "Prerequisite task which loads site and provides automation"
task :environment do
  require "freyia"

  class Hamr < Freyia::Base # rubocop:disable Lint/ConstantDefinitionInBlock
    include Bridgetown::Commands::Automations

    def self.exit_on_failure?
      true
    end

    private

    def site(context: :rake)
      @site ||= begin
        config = Bridgetown::Current.preloaded_configuration
        config.run_initializers!(context:)
        Bridgetown::Site.new(config)
      end
    end
  end

  define_singleton_method :automation do |*args, &block|
    @hamr ||= Hamr.new(source: Dir.pwd, dest: Dir.pwd)
    @hamr.instance_exec(*args, &block)
  end

  %i(site run_initializers).each do |meth|
    define_singleton_method meth do |**kwargs|
      @hamr ||= Hamr.new(source: Dir.pwd, dest: Dir.pwd)
      @hamr.send(:site, **kwargs)
    end
  end
end

# rubocop:disable Bridgetown/NoPutsAllowed
desc "Provides a time zone-aware date string you can use in front matter"
task date: :environment do
  run_initializers

  puts "🗓️  Today's date & time in your site's timezone (#{ENV.fetch("TZ", "NOT SET")}):"
  puts
  puts "➡️  #{Time.now.strftime("%a, %d %b %Y %T %z")}"
end
# rubocop:enable Bridgetown/NoPutsAllowed

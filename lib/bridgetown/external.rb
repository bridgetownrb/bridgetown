# frozen_string_literal: true

module Bridgetown
  module External
    class << self
      #
      # Gems that, if installed, should be loaded.
      # Usually contain subcommands.
      #
      def blessed_gems
        %w(
          bridgetown-compose
          bridgetown-docs
          bridgetown-import
        )
      end

      #
      # Require a gem or file if it's present, otherwise silently fail.
      #
      # names - a string gem name or array of gem names
      #
      def require_if_present(names)
        Array(names).each do |name|
          begin
            require name
          rescue LoadError
            Bridgetown.logger.debug "Couldn't load #{name}. Skipping."
            yield(name, version_constraint(name)) if block_given?
            false
          end
        end
      end

      #
      # The version constraint required to activate a given gem.
      # Usually the gem version requirement is "> 0," because any version
      # will do. In the case of bridgetown-docs, however, we require the exact
      # same version as Bridgetown.
      #
      # Returns a String version constraint in a parseable form for
      # RubyGems.
      def version_constraint(gem_name)
        return "= #{Bridgetown::VERSION}" if gem_name.to_s.eql?("bridgetown-docs")

        "> 0"
      end

      #
      # Require a gem or gems. If it's not present, show a very nice error
      # message that explains everything and is much more helpful than the
      # normal LoadError.
      #
      # names - a string gem name or array of gem names
      #
      def require_with_graceful_fail(names)
        Array(names).each do |name|
          begin
            Bridgetown.logger.debug "Requiring:", name.to_s
            require name
          rescue LoadError => e
            Bridgetown.logger.error "Dependency Error:", <<~MSG
              Yikes! It looks like you don't have #{name} or one of its dependencies installed.
              In order to use Bridgetown as currently configured, you'll need to install this gem.

              If you've run Bridgetown with `bundle exec`, ensure that you have included the #{name}
              gem in your Gemfile as well.

              The full error message from Ruby is: '#{e.message}'

              If you run into trouble, you can find helpful resources at https://bridgetownrb.com/help/!
            MSG
            raise Bridgetown::Errors::MissingDependencyException, name
          end
        end
      end
    end
  end
end

# frozen_string_literal: true

module Bridgetown
  module Utils
    module RequireGems
      class << self
        #
        # Require a gem or gems. If it's not present, show a very nice error
        # message that explains everything and is much more helpful than the
        # normal LoadError.
        #
        # names - a string gem name or array of gem names
        #
        def require_with_graceful_fail(names)
          Array(names).each do |name|
            Bridgetown.logger.debug "Requiring:", name.to_s
            require name.to_s
          rescue LoadError => e
            Bridgetown.logger.error "Dependency Error:", <<~MSG
              Oops! It looks like you don't have #{name} or one of its dependencies installed.
              Please double-check you've added #{name} to your Gemfile.

              If you're stuck, you can find help at https://www.bridgetownrb.com/community

              The full error message from Ruby is: '#{e.message}'
            MSG
            raise Bridgetown::Errors::MissingDependencyException, name
          end
        end
      end
    end
  end
end

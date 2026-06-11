# frozen_string_literal: true

module Bridgetown
  class Container::Policy < Async::Container::Policy
    def child_exit(container, child, status, name:, key:, **options) # rubocop:disable Lint/UnusedMethodArgument, Metrics/ParameterLists
      container.stop
    end
  end
end

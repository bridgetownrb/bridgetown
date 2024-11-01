# frozen_string_literal: true

module Bridgetown
  module Builders
    module DSL
      module Hooks
        # Define a hook to run at some point during the build process
        #
        # @param owner [Symbol] name of the owner (`:site`, `:resource`, etc.)
        # @param event [Symbol] name of the event (`:pre_read`, `:post_render`, etc.)
        # @param method_name [Symbol] name of a Builder method to use, if block isn't provided
        # @param priority [Integer, Symbol] either `:low`, `:normal`, or `:high`, or an integer.
        #   Default is normal (20)
        def hook(
          owner,
          event,
          method_name = nil,
          priority: Bridgetown::Hooks::DEFAULT_PRIORITY,
          &block
        )
          block = method(method_name) if method_name.is_a?(Symbol)

          hook_block = Bridgetown::Hooks.register_one(owner, event, priority:, &block)
          functions << { name:, hook: [owner, event, priority, hook_block] }
        end

        # Define a site post_read hook and add data returned by the block to the site data/signals
        def add_data(data_key)
          hook(:site, :post_read) do
            yield.tap do |value|
              site.data[data_key] = value
              site.signals[data_key] = value
            end
          end
        end
      end
    end
  end
end

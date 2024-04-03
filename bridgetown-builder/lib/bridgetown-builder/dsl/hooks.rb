# frozen_string_literal: true

module Bridgetown
  module Builders
    module DSL
      module Hooks
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

        def add_data(data_key)
          hook(:site, :post_read) do
            site.data[data_key] = yield
          end
        end
      end
    end
  end
end

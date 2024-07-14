# frozen_string_literal: true

module Bridgetown
  module Builders
    module DSL
      module Helpers
        def helpers
          @helpers # could be nil
        end

        def helper(helper_name, method_name = nil, &block)
          m = Module.new

          builder_self = self
          method_name ||= helper_name unless block
          unless method_name
            method_name = :"__helper_#{helper_name}"
            builder_self.define_singleton_method(method_name) do |*args, **kwargs, &block2|
              block.(*args, **kwargs, &block2)
            end
          end
          m.define_method helper_name do |*args, **kwargs, &block2|
            prev_var = builder_self.instance_variable_get(:@helpers)
            builder_self.instance_variable_set(:@helpers, self)
            builder_self.send(method_name, *args, **kwargs, &block2).tap do
              builder_self.instance_variable_set(:@helpers, prev_var)
            end
          end

          Bridgetown::RubyTemplateView::Helpers.include(m)

          functions << { name:, filter: m }
        end
      end
    end
  end
end

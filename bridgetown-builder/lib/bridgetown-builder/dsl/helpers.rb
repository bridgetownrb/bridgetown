# frozen_string_literal: true

module Bridgetown
  module Builders
    module DSL
      module Helpers
        def helper(helper_name, method_name = nil, helpers_scope: false, &block)
          builder_self = self
          m = Module.new

          if block && !helpers_scope
            m.define_method helper_name do |*args|
              builder_self.instance_exec(*args, &block)
            end
          else
            block = method(method_name) if method_name
            m.define_method helper_name, &block
          end

          Bridgetown::RubyTemplateView::Helpers.include(m)

          functions << { name: name, filter: m }
        end
      end
    end
  end
end

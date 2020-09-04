# frozen_string_literal: true

module Bridgetown
  module Builders
    module DSL
      module Helpers
        def helper(filter_name, method_name = nil, &block)
          block = method(method_name) if method_name.is_a?(Symbol)

          m = Module.new
          m.send(:define_method, filter_name, &block)
          Bridgetown::RubyTemplateView::Helpers.include(m)

          functions << { name: name, filter: m }
        end
      end
    end
  end
end

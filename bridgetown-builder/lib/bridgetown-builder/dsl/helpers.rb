# frozen_string_literal: true

module Bridgetown
  module Builders
    module DSL
      module Helpers
        def helper(filter_name, method_name = nil, helpers_scope: false, &block)
          block = if block
                    unless helpers_scope
                      self.class.define_method "_#{filter_name}_helper", &block
                      method("_#{filter_name}_helper")
                    else
                      block
                    end
                  elsif method_name
                    method(method_name)
                  end

          m = Module.new
          m.define_method filter_name, &block
          Bridgetown::RubyTemplateView::Helpers.include(m)

          functions << { name: name, filter: m }
        end
      end
    end
  end
end

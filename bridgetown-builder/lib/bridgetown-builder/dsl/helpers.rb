# frozen_string_literal: true

module Bridgetown
  module Builders
    module DSL
      module Helpers
        def helper(helper_name, method_name = nil, helpers_scope: false, &block)
          block = if block
                    if !helpers_scope
                      self.class.define_method "_#{helper_name}_helper", &block
                      method("_#{helper_name}_helper")
                    else
                      block
                    end
                  elsif method_name
                    method(method_name)
                  end

          m = Module.new
          m.define_method helper_name, &block
          Bridgetown::RubyTemplateView::Helpers.include(m)

          functions << { name: name, filter: m }
        end
      end
    end
  end
end

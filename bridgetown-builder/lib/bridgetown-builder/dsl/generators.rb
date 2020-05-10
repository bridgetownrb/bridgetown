# frozen_string_literal: true

module Bridgetown
  module Builders
    module DSL
      module Generators
        def generator(method_name = nil, &block)
          block = method(method_name) if method_name.is_a?(Symbol)

          custom_name = name
          new_gen = Class.new(Bridgetown::Generator) do
            define_method(:_builder_block) { block }

            @custom_name = custom_name
            class << self
              attr_reader :custom_name
            end

            attr_reader :site

            def inspect
              "#{self.class.custom_name} (Generator)"
            end

            def generate(_site)
              _builder_block.call
            end
          end

          first_low_priority_index = site.generators.find_index { |gen| gen.class.priority == :low }
          site.generators.insert(first_low_priority_index || 0, new_gen.new(site.config))

          functions << { name: name, generator: new_gen }
        end
      end
    end
  end
end

# frozen_string_literal: true

module Bridgetown
  module Builders
    module DSL
      module Generators
        def generator(method_name = nil, &block)
          block = method(method_name) if method_name.is_a?(Symbol)
          local_name = name # pull the name method into a local variable
          builder_priority = self.class.instance_variable_get(:@priority)

          anon_generator = Class.new(Bridgetown::Generator) do
            define_method(:_builder_block) { block }
            define_singleton_method(:custom_name) { local_name }

            attr_reader :site

            priority builder_priority || :low

            def inspect
              "#<#{self.class.custom_name} (Generator)>"
            end

            def generate(_site)
              _builder_block.call
            end
          end

          site.generators << anon_generator.new(site.config)
          site.generators.sort!

          functions << { name: name, generator: anon_generator }
        end
      end
    end
  end
end

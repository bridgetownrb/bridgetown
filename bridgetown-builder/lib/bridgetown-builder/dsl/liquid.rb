# frozen_string_literal: true

module Bridgetown
  module Builders
    module DSL
      module Liquid
        def filters
          @filters # could be nil
        end

        def filters_context
          filters&.instance_variable_get(:@context)
        end

        def liquid_filter(filter_name, method_name = nil, filters_scope: false, &block)
          m = Module.new

          if block && filters_scope
            Deprecator.deprecation_message(
              "The `filters_scope' functionality is deprecated. Use the `filters' builder " \
              "method to access the filters scope in your plugin."
            )
            m.define_method filter_name, &block
          else
            builder_self = self
            method_name ||= filter_name unless block
            unless method_name
              method_name = :"__filter_#{filter_name}"
              builder_self.define_singleton_method(method_name) do |*args, **kwargs|
                block.(*args, **kwargs) # rubocop:disable Performance/RedundantBlockCall
              end
            end
            m.define_method filter_name do |*args, **kwargs|
              prev_var = builder_self.instance_variable_get(:@filters)
              builder_self.instance_variable_set(:@filters, self)
              builder_self.send(method_name, *args, **kwargs).tap do
                builder_self.instance_variable_set(:@filters, prev_var)
              end
            end
          end

          ::Liquid::Template.register_filter(m)

          functions << { name:, filter: m }
        end

        def liquid_tag(tag_name, method_name = nil, as_block: false, &block)
          method_name ||= tag_name unless block
          block = method(method_name) if method_name
          local_name = name # pull the name method into a local variable

          tag_class = as_block ? ::Liquid::Block : ::Liquid::Tag
          tag = Class.new(tag_class) do
            define_method(:_builder_block) { block }
            define_singleton_method(:custom_name) { local_name }

            def inspect
              "#<#{self.class.custom_name} (Liquid Tag)>"
            end

            attr_reader :content, :context

            def render(context)
              @context = context
              @content = super if is_a?(::Liquid::Block)
              _builder_block.call(@markup.strip, self)
            end
          end

          ::Liquid::Template.register_tag tag_name, tag
          functions << { name:, tag: [tag_name, tag] }
        end
      end
    end
  end
end

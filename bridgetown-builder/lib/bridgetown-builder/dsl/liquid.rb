# frozen_string_literal: true

module Bridgetown
  module Builders
    module DSL
      module Liquid
        def liquid_filter(filter_name, method_name = nil, &block)
          block = method(method_name) if method_name.is_a?(Symbol)

          m = Module.new
          m.send(:define_method, filter_name, &block)
          ::Liquid::Template.register_filter(m)

          functions << { name: name, filter: m }
        end

        def liquid_tag(tag_name, method_name = nil, as_block: false, &block)
          block = method(method_name) if method_name.is_a?(Symbol)

          custom_name = name
          tag_class = as_block ? ::Liquid::Block : ::Liquid::Tag
          tag = Class.new(tag_class) do
            define_method(:_builder_block) { block }

            @custom_name = custom_name
            class << self
              attr_reader :custom_name
            end

            def inspect
              "#{self.class.custom_name} (Liquid Tag)"
            end

            attr_reader :site, :content, :context

            def render(context)
              @context = context
              @site = context.registers[:site]
              @content = super if is_a?(::Liquid::Block)
              _builder_block.call(@markup.strip, self)
            end
          end

          ::Liquid::Template.register_tag tag_name, tag
          functions << { name: name, tag: [tag_name, tag] }
        end
      end
    end
  end
end

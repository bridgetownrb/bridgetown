# frozen_string_literal: true

module Bridgetown
  module Builders
    module DSL
      module Tags
        def liquid_filter(filter_name, &block)
          m = Module.new
          m.send(:define_method, filter_name, &block)
          Liquid::Template.register_filter(m)

          functions << { name: name, filter: m }
        end

        def liquid_tag(tag_name, block_tag: false, &block)
          custom_name = name
          tag_class = block_tag ? Liquid::Block : Liquid::Tag
          tag = Class.new(tag_class) do
            @render_block = block
            @custom_name = custom_name

            class << self
              attr_reader :render_block
              attr_reader :custom_name
            end

            def inspect
              "#{self.class.custom_name} (Liquid Tag)"
            end

            attr_reader :site

            def render(context)
              @site = context.registers[:site]
              @content = super if is_a?(Liquid::Block)
              block = self.class.render_block
              instance_exec(
                @markup.strip, context.registers[:page], &block
              )
            end
          end

          Liquid::Template.register_tag tag_name, tag
          functions << { name: name, tag: [tag_name, tag] }
        end
      end
    end
  end
end

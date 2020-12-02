# frozen_string_literal: true

require "digest"
require "active_support/core_ext/hash/keys"

module Bridgetown
  class RubyTemplateView
    require "bridgetown-core/helpers"

    attr_reader :layout, :page, :paginator, :site, :content

    def initialize(convertible)
      if convertible.is_a?(Layout)
        @layout = convertible
        @page = layout.current_document
        @content = layout.current_document_output
      else
        @layout = convertible.site.layouts[convertible.data["layout"]]
        @page = convertible
      end
      @paginator = page.paginator if page.respond_to?(:paginator)
      @site = page.site
    end

    def partial(_partial_name, _options = {})
      raise "Must be implemented in a subclass"
    end

    def render(item, options = {}, &block)
      if item.respond_to?(:render_in)
        previous_buffer_state = @_erbout
        @_erbout = Bridgetown::ERBBuffer.new

        @in_view_component ||= defined?(::ViewComponent::Base) && item.is_a?(::ViewComponent::Base)
        result = item.render_in(self, &block)
        @in_view_component = false

        @_erbout = previous_buffer_state
        result
      else
        partial(item, options, &block)
      end
    end

    def site_drop
      site.site_payload.site
    end

    def liquid_render(component, options = {}, &block)
      options[:_block_content] = capture(&block) if block && respond_to?(:capture)
      render_statement = _render_statement(component, options)

      template = site.liquid_renderer.file(
        "#{page.path}.#{Digest::SHA2.hexdigest(render_statement)}"
      ).parse(render_statement)
      template.warnings.each do |e|
        Bridgetown.logger.warn "Liquid Warning:",
                               LiquidRenderer.format_error(e, path || document.relative_path)
      end
      template.render!(options.deep_stringify_keys, _liquid_context)
    end

    def helpers
      @helpers ||= Helpers.new(self, site)
    end

    def method_missing(method, *args, &block)
      if helpers.respond_to?(method.to_sym)
        helpers.send method.to_sym, *args, &block
      else
        super
      end
    end

    def respond_to_missing?(method, include_private = false)
      helpers.respond_to?(method.to_sym, include_private) || super
    end

    private

    def _render_statement(component, options)
      render_statement = if options[:_block_content]
                           ["{% rendercontent \"#{component}\""]
                         else
                           ["{% render \"#{component}\""]
                         end
      unless options.empty?
        render_statement << ", " + options.keys.map { |k| "#{k}: #{k}" }.join(", ")
      end
      render_statement << " %}"
      if options[:_block_content]
        render_statement << options[:_block_content]
        render_statement << "{% endrendercontent %}"
      end
      render_statement.join
    end

    def _liquid_context
      {
        registers: {
          site: site,
          page: page.to_liquid,
          cached_partials: Bridgetown::Converters::LiquidTemplates.cached_partials,
        },
        strict_filters: site.config["liquid"]["strict_filters"],
        strict_variables: site.config["liquid"]["strict_variables"],
      }
    end
  end
end

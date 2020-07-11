# frozen_string_literal: true

require "digest"

module Bridgetown
  class RubyTemplateView
    class Helpers
      include Bridgetown::Filters
    end

    attr_reader :layout, :page, :site, :content

    def initialize(convertible)
      if convertible.is_a?(Layout)
        @layout = convertible
        @page = layout.current_document
        @content = layout.current_document_output
      else
        @page = convertible
      end
      @site = page.site
    end

    def partial(_partial_name, _options = {})
      raise "Must be implemented in a subclass"
    end

    def site_drop
      site.site_payload.site
    end

    def liquid_render(component, options = {})
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
      @helpers ||= Helpers.new
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
      render_statement = ["{% render \"#{component}\""]
      unless options.empty?
        render_statement << ", " + options.keys.map { |k| "#{k}: #{k}" }.join(", ")
      end
      render_statement << " %}"
      render_statement.join
    end

    def _liquid_context
      {
        registers: {
          site: site,
          page: page,
          cached_partials: Bridgetown::Renderer.cached_partials,
        },
        strict_filters: site.config["liquid"]["strict_filters"],
        strict_variables: site.config["liquid"]["strict_variables"],
      }
    end
  end
end

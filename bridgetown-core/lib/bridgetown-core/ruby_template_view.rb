# frozen_string_literal: true

module Bridgetown
  class RubyTemplateView
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

    def partial_render(_partial_name, _options = {})
      raise "Must be implemented in a subclass"
    end

    def site_drop
      site.site_payload.site
    end

    def liquid_render(component, options = {})
      render_statement = _render_statement(component, options).join

      template = site.liquid_renderer.file(
        "#{page.path}#{render_statement.hash}"
      ).parse(render_statement)
      template.warnings.each do |e|
        Bridgetown.logger.warn "Liquid Warning:",
                               LiquidRenderer.format_error(e, path || document.relative_path)
      end
      template.render!(options.deep_stringify_keys, _liquid_context)
    end

    private

    def _render_statement(component, options)
      render_statement = ["{% render \"#{component}\""]
      unless options.empty?
        render_statement << ", " + options.keys.map { |k| "#{k}: #{k}" }.join(", ")
      end
      render_statement << " %}"
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

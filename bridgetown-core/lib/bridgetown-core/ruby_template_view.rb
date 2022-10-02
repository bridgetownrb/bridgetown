# frozen_string_literal: true

require "digest"

module Bridgetown
  class RubyTemplateView
    require "bridgetown-core/helpers"

    attr_reader :layout, :resource, :paginator, :site, :content
    alias_method :page, :resource

    def initialize(convertible)
      if convertible.is_a?(Layout)
        @layout = convertible
        @resource = layout.current_document
        @content = layout.current_document_output
      else
        @layout = convertible.site.layouts[convertible.data["layout"]]
        @resource = convertible
      end
      @paginator = resource.paginator if resource.respond_to?(:paginator)
      @site = resource.site
    end

    def data
      resource.data
    end

    def partial(_partial_name = nil, **_options)
      raise "Must be implemented in a subclass"
    end

    def render(item, **options, &block)
      if item.respond_to?(:render_in)
        result = item.render_in(self, &block)
        result&.html_safe
      else
        partial(item, **options, &block)&.html_safe
      end
    end

    def collections
      site.collections
    end

    def site_drop
      site.site_payload.site
    end

    def liquid_render(component, options = {}, &block)
      options[:_block_content] = capture(&block) if block && respond_to?(:capture)
      render_statement = _render_statement(component, options)

      template = site.liquid_renderer.file(
        "#{resource.path}.#{Digest::SHA2.hexdigest(render_statement)}"
      ).parse(render_statement)
      template.warnings.each do |e|
        Bridgetown.logger.warn "Liquid Warning:",
                               LiquidRenderer.format_error(e, path || document.relative_path)
      end
      template.render!(options.deep_stringify_keys, _liquid_context).html_safe
    end

    def helpers
      @helpers ||= Helpers.new(self, site)
    end

    def method_missing(method_name, *args, **kwargs, &block)
      if helpers.respond_to?(method_name.to_sym)
        helpers.send method_name.to_sym, *args, **kwargs, &block
      else
        super
      end
    end

    def respond_to_missing?(method_name, include_private = false)
      helpers.respond_to?(method_name.to_sym, include_private) || super
    end

    def inspect
      "#<#{self.class} layout=#{layout&.label} resource=#{resource.relative_path}>"
    end

    private

    def _render_statement(component, options)
      render_statement = if options[:_block_content]
                           ["{% rendercontent \"#{component}\""]
                         else
                           ["{% render \"#{component}\""]
                         end
      unless options.empty?
        render_statement << ", #{options.keys.map { |k| "#{k}: #{k}" }.join(", ")}"
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
          page: resource.to_liquid,
          cached_partials: Bridgetown::Converters::LiquidTemplates.cached_partials,
        },
        strict_filters: site.config["liquid"]["strict_filters"],
        strict_variables: site.config["liquid"]["strict_variables"],
      }
    end

    def _partial_path(partial_name, ext)
      partial_name = partial_name.split("/").tap { _1.last.prepend("_") }.join("/")

      # TODO: see if there's a workaround for this to speed up performance
      site.in_source_dir(site.config[:partials_dir], "#{partial_name}.#{ext}")
    end
  end
end

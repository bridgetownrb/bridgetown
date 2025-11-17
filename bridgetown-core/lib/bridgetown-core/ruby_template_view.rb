# frozen_string_literal: true

require "digest"
require "serbea/pipeline"
require "streamlined/helpers"
require "streamlined/renderable"

module Bridgetown
  module Streamlined
    include ::Streamlined::Renderable
    include Serbea::Pipeline::Helper
    include ERBCapture

    def helper(name, &helper_block)
      self.class.define_method(name) do |*args, **kwargs, &block|
        helper_block.call(*args, **kwargs, &block)
      end
    end
    alias_method :macro, :helper
  end

  class RubyTemplateView
    require "bridgetown-core/helpers"

    using Bridgetown::Refinements
    include Bridgetown::Streamlined

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
      @support_data_as_view_methods = @site.config.support_data_as_view_methods
    end

    def data = resource.data

    def collections = site.collections

    def site_drop = site.site_payload.site

    def partial(_partial_name = nil, **_options) = raise("Must be implemented in a subclass")

    def render(item, **, &)
      if item.respond_to?(:render_in)
        result = item.render_in(self, &)
        result&.html_safe
      else
        partial(item, **, &)&.html_safe
      end
    end

    def liquid_render(component, **options, &block)
      options[:_block_content] = capture(&block) if block && respond_to?(:capture)
      render_statement = _render_statement(component, options)

      template = site.liquid_renderer.file(
        "#{resource.path}.#{Digest::SHA2.hexdigest(render_statement)}"
      ).parse(render_statement)
      template.warnings.each do |e|
        Bridgetown.logger.warn "Liquid Warning:",
                               LiquidRenderer.format_error(e, path || document.relative_path)
      end
      template.render!(options.as_dots, _liquid_context).html_safe
    end

    def helpers
      @helpers ||= Helpers.new(self, site)
    end

    def data_key?(key, *args, **kwargs)
      return false unless @support_data_as_view_methods

      args.empty? && kwargs.empty? && !block_given? && data.key?(key)
    end

    def method_missing(method_name, ...)
      if helpers.respond_to?(method_name.to_sym)
        helpers.send(method_name.to_sym, ...)
      elsif data_key?(method_name, ...)
        data[method_name]
      else
        super
      end
    end

    def respond_to_missing?(method_name, include_private = false)
      helpers.respond_to?(method_name.to_sym, include_private) || super
    end

    def inspect = "#<#{self.class} layout=#{layout&.label} resource=#{resource.relative_path}>"

    private

    def _render_statement(component, options)
      render_statement = options[:_block_content] ?
                           ["{% rendercontent \"#{component}\""] :
                           ["{% render \"#{component}\""]
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
          site:,
          page: resource.to_liquid,
          cached_partials: Bridgetown::Converters::LiquidTemplates.cached_partials,
        },
        strict_filters: site.config["liquid"]["strict_filters"],
        strict_variables: site.config["liquid"]["strict_variables"],
      }
    end

    def _partial_path(partial_name, ext)
      partial_name = partial_name.split("/").tap { _1.last.prepend("_") }.join("/")

      site.in_source_dir(site.config[:partials_dir], "#{partial_name}.#{ext}")
    end
  end
end

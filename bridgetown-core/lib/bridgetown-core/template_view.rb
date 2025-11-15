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

  class TemplateView
    require "bridgetown-core/helpers"

    using Bridgetown::Refinements
    include Bridgetown::Streamlined

    attr_reader :layout, :resource, :paginator, :site, :content
    alias_method :page, :resource

    class << self
      attr_accessor :extname_list

      # View renderers can provide one or more extensions they accept. Examples:
      #
      # * `input :erb`
      # * `input %i(rb ruby)`
      #
      # @param extnames [Array<Symbol>] extensions
      def input(extnames)
        extnames = Array(extnames)
        self.extname_list ||= []
        self.extname_list += extnames.map { |e| ".#{e.to_s.downcase}" }
      end

      def virtual_view
        # if site object has changed, clear previous state
        @virtual_res = @virtual_view = nil if @virtual_res&.site != Bridgetown::Current.site

        @virtual_res ||= Bridgetown::Model::Base.build(
          { site: Bridgetown::Current.site }.as_dots, :pages, "VIRTUAL", {}
        ).to_resource
        @virtual_view ||= new(@virtual_res)
      end

      def render(...) = virtual_view.render(...)
    end

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

    def template_view_classes
      @template_view_classes ||= TemplateView.descendants.each_with_object({}) do |klass, hsh|
        klass.extname_list.each do |ext|
          hsh[ext] = klass
        end
      end
    end

    def render(item, **options, &)
      if item.respond_to?(:render_in)
        result = item.render_in(self, &)
        result&.html_safe
      else
        partial(item, **options, &)&.html_safe
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

    def partial(partial_name = nil, **options, &)
      partial_name = options[:template] if partial_name.nil? && options[:template]
      found_file = _locate_partial(partial_name)
      view_class = _view_class_for_partial(found_file)

      view_class.virtual_view.tap do |view|
        view.resource.roda_app = self.class.virtual_view.resource.roda_app
      end.partial(partial_name, **options, &)
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

    def _locate_partial(partial_name)
      found_file = nil

      # TODO: make this configurable
      %w(erb serb rb slim haml).each do |ext|
        next if found_file

        path = _partial_path(partial_name, ext)
        found_file = File.exist?(path) && path
      end

      raise "No matching partial could be found for #{partial_name}" unless found_file

      found_file
    end

    def _view_class_for_partial(path)
      view_class = template_view_classes[File.extname(path)]

      raise "No view renderer could be found for #{File.basename(path)}" unless view_class

      view_class
    end
  end

  # TODO: this class alias is deprecated and will be removed in the next major Bridgetown release
  RubyTemplateView = TemplateView
end

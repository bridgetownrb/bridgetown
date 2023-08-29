# frozen_string_literal: true

module Bridgetown
  class RubyTemplateView
    class Helpers
      include Bridgetown::Filters
      include Bridgetown::Filters::FromLiquid

      # @return [Bridgetown::RubyTemplateView]
      attr_reader :view

      # @return [Bridgetown::Site]
      attr_reader :site

      Context = Struct.new(:registers)

      # @param view [Bridgetown::RubyTemplateView]
      # @param site [Bridgetown::Site]
      def initialize(view, site)
        @view = view
        @site = site

        # duck typing for Liquid context
        @context = Context.new({ site: site })
      end

      def asset_path(asset_type)
        Bridgetown::Utils.parse_frontend_manifest_file(site, asset_type.to_s)
      end
      alias_method :webpack_path, :asset_path

      def live_reload_dev_js
        Bridgetown::Utils.live_reload_js(site)
      end

      # @param pairs [Hash] A hash of key/value pairs.
      #
      # @return [String] Space-separated keys where the values are truthy.
      def class_map(pairs = {})
        pairs.select { |_key, truthy| truthy }.keys.join(" ")
      end

      # Convert a Markdown string into HTML output.
      #
      # @param input [String] the Markdown to convert, if no block is passed
      # @return [String]
      def markdownify(input = nil, &block)
        content = Bridgetown::Utils.reindent_for_markdown(
          block.nil? ? input.to_s : view.capture(&block)
        )
        converter = site.find_converter_instance(Bridgetown::Converters::Markdown)
        safe(converter.convert(content).strip)
      end

      # This helper will generate the correct permalink URL for the file path.
      #
      # @param relative_path [String, Object] source file path, e.g.
      #   "_posts/2020-10-20-my-post.md", or object that responds to either
      #   `url` or `relative_url`
      # @return [String] the permalink URL for the file
      def url_for(relative_path)
        if relative_path.respond_to?(:relative_url)
          return safe(relative_path.relative_url) # new resource engine
        elsif relative_path.respond_to?(:url)
          return safe(relative_url(relative_path.url)) # old legacy engine
        elsif relative_path.to_s.start_with?("/", "http", "#", "mailto:", "tel:")
          return safe(relative_path)
        end

        find_relative_url_for_path(relative_path)
      end
      alias_method :link, :url_for

      # @param relative_path [String] source file path, e.g.
      #   "_posts/2020-10-20-my-post.md"
      # @raise [ArgumentError] if the file cannot be found
      def find_relative_url_for_path(relative_path)
        site.each_site_file do |item|
          if item.relative_path.to_s == relative_path ||
              item.relative_path.to_s == "/#{relative_path}"
            return safe(item.respond_to?(:relative_url) ? item.relative_url : relative_url(item))
          end
        end

        raise ArgumentError, <<~MSG
          Could not find document '#{relative_path}' in 'url_for' helper.

          Make sure the document exists and the path is correct.
        MSG
      end

      # This helper will generate the correct permalink URL for the file path.
      #
      # @param text [String] the content inside the anchor tag
      # @param relative_path [String, Object] source file path, e.g.
      #   "_posts/2020-10-20-my-post.md", or object that responds to `url`
      # @param options [Hash] key-value pairs of HTML attributes to add to the tag
      # @return [String] the anchor tag HTML
      # @raise [ArgumentError] if the file cannot be found
      def link_to(text, relative_path = nil, options = {}, &block)
        if block.present?
          options = relative_path || {}
          relative_path = text
          text = view.respond_to?(:capture) ? view.capture(&block) : yield
        elsif relative_path.nil?
          raise ArgumentError, "You must provide a relative path"
        end
        segments = attributes_from_options({ href: url_for(relative_path) }.merge(options))

        safe("<a #{segments}>#{text}</a>")
      end

      # Create a set of attributes from a hash.
      #
      # @param options [Hash] key-value pairs of HTML attributes
      # @return [String]
      def attributes_from_options(options)
        segments = []
        options.each do |attr, option|
          attr = dashed(attr)
          if option.is_a?(Hash)
            option = option.transform_keys { |key| "#{attr}-#{dashed(key)}" }
            segments << attributes_from_options(option)
          else
            segments << attribute_segment(attr, option)
          end
        end
        safe(segments.join(" "))
      end

      # Forward all arguments to I18n.t method
      #
      # @return [String] the translated string
      # @see I18n
      def t(*args, **kwargs)
        I18n.send :t, *args, **kwargs
      end

      # Forward all arguments to I18n.l method
      #
      # @return [String] the localized string
      # @see I18n
      def l(*args, **kwargs)
        I18n.send :l, *args, **kwargs
      end

      # For template contexts where ActiveSupport's output safety is loaded, we
      # can ensure a string has been marked safe
      #
      # @param input [Object]
      # @return [String]
      def safe(input)
        input.to_s.html_safe
      end
      alias_method :raw, :safe

      # Define a new content slot
      #
      # @param name [String, Symbol] name of the slot
      # @param input [String] content if not supplying a block
      # @param replace [Boolean] set to true to replace any previously defined slot with same name
      # @param transform [Boolean] set to false to avoid template-based transforms (Markdown, etc.)
      # @return [void]
      def slot(name, input = nil, replace: false, transform: true, &block)
        content = Bridgetown::Utils.reindent_for_markdown(
          block.nil? ? input.to_s : view.capture(&block)
        )

        resource = if view.respond_to?(:resource)
                     # We're in a resource rendering context
                     view.resource
                   elsif view.respond_to?(:view_context)
                     # We're in a component rendering context, although it's
                     # likely the component's own `slot` method will be called
                     # in this context
                     view.view_context.resource
                   end

        name = name.to_s
        resource.slots.reject! { _1.name == name } if replace
        resource.slots << Slot.new(
          name: name,
          content: content,
          context: resource,
          transform: transform
        )

        nil
      end

      # Render out a content slot
      #
      # @param name [String, Symbol] name of the slot
      # @param input [String] default content if slot isn't defined and no block provided
      # @return [String]
      def slotted(name, default_input = nil, &default_block) # rubocop:todo Metrics
        resource = if view.respond_to?(:resource)
                     view.resource
                   elsif view.respond_to?(:view_context)
                     view.view_context.resource
                   end

        return unless resource

        name = name.to_s
        filtered_slots = resource.slots.select do |slot|
          slot.name == name
        end

        return filtered_slots.map(&:content).join.html_safe if filtered_slots.length.positive?

        default_block.nil? ? default_input.to_s : view.capture(&default_block)
      end

      # Check if a content slot has been defined
      #
      # @return [Boolean]
      def slotted?(name)
        resource = if view.respond_to?(:resource)
                     view.resource
                   elsif view.respond_to?(:view_context)
                     view.view_context.resource
                   end

        return false unless resource

        name = name.to_s
        resource.slots.any? do |slot|
          slot.name == name
        end
      end

      def dsd(input = nil, &block)
        tmpl_content = block.nil? ? input.to_s : view.capture(&block)

        Bridgetown::Utils.dsd_tag(tmpl_content)
      end

      def dsd_style
        tmpl_path = caller_locations(1, 2).find do |loc|
                      loc.label.include?("method_missing").!
                    end&.path

        return unless tmpl_path # virtually guaranteed not to happen

        tmpl_basename = File.basename(tmpl_path, ".*")
        style_path = File.join(File.dirname(tmpl_path), "#{tmpl_basename}.dsd.css")

        unless File.file?(style_path)
          raise Bridgetown::Errors::FatalException, "Missing stylesheet at #{style_path}"
        end

        style_tag = site.tmp_cache["dsd_style:#{style_path}"] ||=
          "<style>#{File.read(style_path)}</style>"

        style_tag.html_safe
      end

      private

      # Covert an underscored value into a dashed string.
      #
      # @example "foo_bar_baz" => "foo-bar-baz"
      #
      # @param value [String|Symbol]
      # @return [String]
      def dashed(value)
        value.to_s.tr("_", "-")
      end

      # Create an attribute segment for a tag.
      #
      # @param attr [String] the HTML attribute name
      # @param value [String] the attribute value
      # @return [String]
      def attribute_segment(attr, value)
        "#{attr}=\"#{Utils.xml_escape(value)}\""
      end
    end
  end
end

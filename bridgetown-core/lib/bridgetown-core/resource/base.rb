# frozen_string_literal: true

module Bridgetown
  module Resource
    class Base # rubocop:todo Metrics/ClassLength
      include Comparable
      include Bridgetown::Publishable
      include Bridgetown::LayoutPlaceable
      include Bridgetown::LiquidRenderable
      include Bridgetown::Localizable

      # @return [HashWithDotAccess::Hash]
      attr_reader :data

      # @return [Destination]
      attr_reader :destination

      # @return [Bridgetown::Model::Base]
      attr_reader :model

      # @return [Bridgetown::Site]
      attr_reader :site

      # @return [Array<Bridgetown::Slot>]
      attr_reader :slots

      # @return [String]
      attr_accessor :content, :untransformed_content, :output

      DATE_FILENAME_MATCHER = %r!^(?>.+/)*?(\d{2,4}-\d{1,2}-\d{1,2})-([^/]*)(\.[^.]+)$!

      # @param site [Bridgetown::Site]
      # @param origin [Bridgetown::Resource::Origin]
      def initialize(model:)
        @model = model
        @site = model.site
        @data = collection.data? ? HashWithDotAccess::Hash.new : front_matter_defaults
        @slots = []

        trigger_hooks :post_init
      end

      # Collection associated with this resource
      #
      # @return [Bridgetown::Collection]
      def collection
        model.collection
      end

      # Layout associated with this resource
      # This will output a warning if the layout can't be found.
      #
      # @return [Bridgetown::Layout]
      def layout
        return @layout if @layout
        return if no_layout?

        @layout = site.layouts[data.layout].tap do |layout|
          unless layout
            Bridgetown.logger.warn "Resource:", "Layout '#{data.layout}' " \
                                                "requested via #{relative_path} does not exist."
          end
        end
      end

      # The relative path of source file or file-like origin
      #
      # @return [Pathname]
      def relative_path
        model.origin.relative_path
      end

      # @return [Bridgetown::Resource::Transformer]
      def transformer
        @transformer ||= Bridgetown::Resource::Transformer.new(self)
      end

      # @return [Bridgetown::Resource::Relations]
      def relations
        @relations ||= Bridgetown::Resource::Relations.new(self)
      end

      # Loads in any default front matter associated with the resource.
      #
      # @return [HashWithDotAccess::Hash]
      def front_matter_defaults
        site.frontmatter_defaults.all(
          relative_path.to_s,
          collection.label.to_sym
        ).with_dot_access
      end

      # Merges new data into the existing data hash.
      #
      # @param new_data [HashWithDotAccess::Hash]
      def data=(new_data)
        @data = @data.merge(new_data)
      end

      # @return [Bridgetown::Resource::Base]
      def read!
        self.data = model.data_attributes
        self.content = model.content # could be nil

        unless collection.data?
          self.untransformed_content = content
          normalize_categories_and_tags
          import_taxonomies_from_data
          ensure_default_data
          transformer.execute_inline_ruby!
          set_date_from_string(data.date)
        end

        @destination = Destination.new(self) if requires_destination?

        trigger_hooks :post_read

        self
      end
      alias_method :read, :read! # TODO: eventually use the bang version only

      def transform!
        transformer.process! unless collection.data?

        self
      end

      def trigger_hooks(hook_name, *args)
        Bridgetown::Hooks.trigger collection.label.to_sym, hook_name, self, *args if collection
        Bridgetown::Hooks.trigger :resources, hook_name, self, *args
      end

      def around_hook(hook_suffix)
        trigger_hooks :"pre_#{hook_suffix}"
        yield
        trigger_hooks :"post_#{hook_suffix}"
      end

      # @return [String]
      def relative_path_basename_without_prefix
        return_path = Pathname.new("")
        relative_path.each_filename do |filename|
          if matches = DATE_FILENAME_MATCHER.match(filename) # rubocop:disable Lint/AssignmentInCondition
            filename = matches[2] + matches[3]
          end

          return_path += filename unless filename.starts_with?("_")
        end

        (return_path.dirname + return_path.basename(".*")).to_s
      end

      # @return [String]
      def basename_without_ext
        relative_path.basename(".*").to_s
      end

      # @return [String]
      def extname
        relative_path.extname
      end

      # @return [String, nil]
      def permalink
        data&.permalink
      end

      # @return [String]
      def path
        (model.origin.respond_to?(:original_path) ? model.origin.original_path : relative_path).to_s
      end

      # @return [String]
      def absolute_url
        format_url destination&.absolute_url
      end

      # @return [String]
      def relative_url
        format_url destination&.relative_url
      end

      # @return [String]
      def id
        model.origin.id
      end

      # @return [String]
      def output_ext
        destination&.output_ext
      end

      def date
        data["date"] ||= site.time
      end

      # Ask the configured summary extension to output a summary of the content,
      # otherwise return the first line.
      #
      # @return [String]
      def summary
        return summary_extension_output if respond_to?(:summary_extension_output)

        content.to_s.strip.lines.first.to_s.strip.html_safe
      end

      # @return [Hash<String, Hash<String => Bridgetown::Resource::TaxonomyType,
      #   Array<Bridgetown::Resource::TaxonomyTerm>>>]
      def taxonomies
        @taxonomies ||= site.taxonomy_types.values.each_with_object(
          HashWithDotAccess::Hash.new
        ) do |taxonomy, hsh|
          hsh[taxonomy.label] = {
            type: taxonomy,
            terms: [],
          }
        end
      end

      def requires_destination?
        collection.write? && data.config&.output != false
      end
      alias_method :write?, :requires_destination?

      # Write the generated resource file to the destination directory.
      def write(_dest = nil)
        destination.write(output)
        trigger_hooks(:post_write)
      end

      def to_s
        output || content || ""
      end

      # Create a Liquid-understandable version of this resource.
      #
      # @return [Drops::ResourceDrop] represents this resource's data.
      def to_liquid
        @to_liquid ||= Drops::ResourceDrop.new(self)
      end

      def to_h
        {
          id:,
          absolute_url:,
          relative_path:,
          relative_url:,
          date:,
          data:,
          taxonomies:,
          untransformed_content:,
          content:,
          output:,
        }
      end

      def as_json(*)
        to_h
      end

      def to_json(...)
        as_json(...).to_json(...)
      end

      def inspect
        "#<#{self.class} #{id}>"
      end

      # Compare this resource against another resource.
      # Comparison is a comparison between the 2 dates or paths of the resources.
      #
      # @return [Integer] -1, 0, or +1
      def <=>(other) # rubocop:todo Metrics/AbcSize
        return nil unless other.respond_to?(:data)

        cmp = if data.date.respond_to?(:to_datetime) && other.data.date.respond_to?(:to_datetime)
                data.date.to_datetime <=> other.data.date.to_datetime
              end

        cmp = data["date"] <=> other.data["date"] if cmp.nil?
        cmp = path <=> other.path if cmp.nil? || cmp.zero?
        cmp
      end

      def next_resource
        pos = collection.resources.index { |item| item.equal?(self) }
        collection.resources[pos + 1] if pos && pos < collection.resources.length - 1
      end
      alias_method :next_doc, :next_resource
      alias_method :next, :next_resource

      def previous_resource
        pos = collection.resources.index { |item| item.equal?(self) }
        collection.resources[pos - 1] if pos&.positive?
      end
      alias_method :previous_doc, :previous_resource
      alias_method :previous, :previous_resource

      private

      def ensure_default_data
        determine_locale
        merge_requested_site_data

        slug = if matches = relative_path.to_s.match(DATE_FILENAME_MATCHER) # rubocop:disable Lint/AssignmentInCondition
                 set_date_from_string(matches[1]) unless data.date
                 matches[2]
               else
                 basename_without_ext
               end

        Bridgetown::Utils.chomp_locale_suffix!(slug, data.locale)

        data.slug ||= slug
        data.title ||= Bridgetown::Utils.titleize_slug(slug)
      end

      # Lets you put `site.data.foo.bar` in a front matter variable and it will then get swapped
      # out for the actual site data
      def merge_requested_site_data
        data.each do |k, v|
          next unless v.is_a?(String) && v.starts_with?("site.data.")

          data_path = v.delete_prefix("site.data.")
          data[k] = site.data.dig(*data_path.split("."))
        end
      end

      def set_date_from_string(new_date) # rubocop:disable Naming/AccessorMethodName
        return unless new_date.is_a?(String)

        data.date = Bridgetown::Utils.parse_date(
          new_date,
          "Resource '#{relative_path}' does not have a valid date."
        )
      end

      def normalize_categories_and_tags
        data.categories = Bridgetown::Utils.pluralized_array_from_hash(
          data, :category, :categories
        )
        data.tags = Bridgetown::Utils.pluralized_array_from_hash(
          data, :tag, :tags
        )
      end

      def import_taxonomies_from_data
        taxonomies.each_value do |metadata|
          Array(data[metadata.type.key]).each do |term|
            metadata.terms << TaxonomyTerm.new(
              resource: self, label: term, type: metadata.type
            )
          end
        end
      end

      def determine_locale # rubocop:todo Metrics/AbcSize
        unless data.locale
          data.locale = locale_from_alt_data_or_filename.presence || site.config.default_locale
        end

        return unless data.locale_overrides.is_a?(Hash) && data.locale_overrides&.key?(data.locale)

        data.merge!(data.locale_overrides[data.locale])
      end

      # Look for alternative front matter or look at the filename pattern: slug.locale.ext
      def locale_from_alt_data_or_filename
        found_locale = data.language || data.lang || basename_without_ext.split(".")[1..].last
        return unless found_locale && site.config.available_locales.include?(found_locale.to_sym)

        found_locale.to_sym
      end

      def format_url(url)
        url.to_s.sub(%r{index\.html?$}, "").sub(%r{\.html?$}, "")
      end
    end
  end
end

# frozen_string_literal: true

module Bridgetown
  module Resource
    class Base
      include Comparable
      include Bridgetown::Publishable
      include Bridgetown::LayoutPlaceable
      include Bridgetown::LiquidRenderable

      # @return [HashWithDotAccess::Hash]
      attr_reader :data

      # @return [Destination]
      attr_reader :destination

      # @return [Bridgetown::Model::Base]
      attr_reader :model

      # @return [Bridgetown::Site]
      attr_reader :site

      # @return [String]
      attr_accessor :content, :untransformed_content, :output

      # @!attribute [r] collection
      #   @return [Bridgetown::Collection] collection of this resource

      # @!attribute [r] relative_path
      #   @return [Pathname] the relative path of source file or
      #     file-like origin

      DATE_FILENAME_MATCHER = %r!^(?>.+/)*?(\d{2,4}-\d{1,2}-\d{1,2})-([^/]*)(\.[^.]+)$!.freeze

      # @param site [Bridgetown::Site]
      # @param origin [Bridgetown::Resource::Origin]
      def initialize(model:)
        @model = model
        @site = model.site
        self.data = HashWithDotAccess::Hash.new

        trigger_hooks(:post_init)
      end

      # @return [Bridgetown::Collection]
      def collection
        model.collection
      end

      # @return [Pathname]
      def relative_path
        model.origin.relative_path
      end

      # @return [Bridgetown::Resource::Transformer]
      def transformer
        @transformer ||= Bridgetown::Resource::Transformer.new(self)
      end

      # @param new_data [HashWithDotAccess::Hash]
      def data=(new_data)
        unless new_data.is_a?(HashWithDotAccess::Hash)
          raise "#{self.class} data should be of type HashWithDotAccess::Hash"
        end

        @data = new_data
        @data.default_proc = proc do |_, key|
          site.frontmatter_defaults.find(
            relative_path.to_s,
            collection.label.to_sym,
            key.to_s
          )
        end
      end

      # @return [Bridgetown::Resource::Base]
      def read!
        self.data = model.data_attributes
        self.content = model.content # could be nil

        unless collection.data?
          self.untransformed_content = content
          determine_slug_and_date
          normalize_categories_and_tags
          import_taxonomies_from_data
        end

        @destination = Destination.new(self) if requires_destination?

        trigger_hooks(:post_read)

        self
      end
      alias_method :read, :read! # TODO: eventually use the bang version only

      def transform!
        transformer.process! unless collection.data?
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

      def path
        (model.origin.respond_to?(:original_path) ? model.origin.original_path : relative_path).to_s
      end

      def absolute_url
        format_url destination&.absolute_url
      end

      def relative_url
        format_url destination&.relative_url
      end
      alias_method :id, :relative_url

      def date
        data["date"] ||= site.time # TODO: this doesn't reflect documented behavior
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

      def write?
        requires_destination? && site.publisher.publish?(self)
      end

      # Write the generated Document file to the destination directory.
      #
      # dest - The String path to the destination dir.
      #
      # Returns nothing.
      def write(_dest = nil)
        destination.write(output)
        trigger_hooks(:post_write)
      end

      def to_s
        output || content || ""
      end

      # Create a Liquid-understandable version of this resource.
      #
      # @return [Drops::DocumentDrop] represents this resource's data.
      def to_liquid
        @to_liquid ||= Drops::ResourceDrop.new(self)
      end

      def inspect
        "#<#{self.class} [#{collection.label}] #{relative_path}>"
      end

      # Compare this document against another document.
      # Comparison is a comparison between the 2 paths of the documents.
      #
      # Returns -1, 0, +1 or nil depending on whether this doc's path is less than,
      #   equal or greater than the other doc's path. See String#<=> for more details.
      def <=>(other) # rubocop:todo Metrics/AbcSize
        return nil unless other.respond_to?(:data)

        if data.date.respond_to?(:to_datetime) && other.data.date.respond_to?(:to_datetime)
          return data.date.to_datetime <=> other.data.date.to_datetime
        end

        cmp = data["date"] <=> other.data["date"]
        cmp = path <=> other.path if cmp.nil? || cmp.zero?
        cmp
      end

      def next_resource
        pos = collection.resources.index { |item| item.equal?(self) }
        collection.resources[pos + 1] if pos && pos < collection.resources.length - 1
      end
      alias_method :next_doc, :next_resource

      def previous_resource
        pos = collection.docs.index { |item| item.equal?(self) }
        collection.resources[pos - 1] if pos&.positive?
      end
      alias_method :previous_doc, :previous_resource

      private

      def determine_slug_and_date
        return unless relative_path.to_s =~ DATE_FILENAME_MATCHER

        new_date, slug = Regexp.last_match.captures
        modify_date(new_date)

        slug.gsub!(%r!\.*\z!, "")
        data.slug ||= slug
      end

      def modify_date(new_date)
        if !data.date || data.date.to_i == site.time.to_i
          data.date = Utils.parse_date(
            new_date,
            "Document '#{relative_path}' does not have a valid date in the #{model}."
          )
        end
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
        taxonomies.each do |_label, metadata|
          Array(data[metadata.type.key]).each do |term|
            metadata.terms << TaxonomyTerm.new(
              resource: self, label: term, type: metadata.type
            )
          end
        end
      end

      def format_url(url)
        url.to_s.sub(%r{index\.html?$}, "").sub(%r{\.html?$}, "")
      end
    end
  end
end

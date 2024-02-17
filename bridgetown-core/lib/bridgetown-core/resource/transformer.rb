# frozen_string_literal: true

module Bridgetown
  module Resource
    class Transformer
      include Transformable

      # @return [Array<Hash>]
      attr_reader :conversions

      # @return [Bridgetown::Resource::Base]
      attr_reader :resource

      # @return [Bridgetown::Site]
      attr_reader :site

      def initialize(resource)
        @resource = resource
        @site = resource.site
        @conversions = []
      end

      # @return [String]
      def output_ext
        @output_ext ||= output_ext_from_converters
      end

      # @return [String]
      def final_ext
        output_ext # we always need this to get run

        permalink_ext || output_ext
      end

      def process! # rubocop:disable Metrics/AbcSize
        Bridgetown.logger.debug "Transforming:", resource.relative_path
        resource.around_hook :render do
          resource.content = transform_content(resource) do |converter, index, output|
            conversions[index] = {
              type: :content,
              converter:,
              output: Bridgetown.env.production? ? nil : output,
              output_ext: conversions[index]&.dig(:output_ext) ||
                converter.output_ext(resource.extname),
            }
          end
          resource.place_in_layout? ? place_into_layouts : resource.output = resource.content.dup
        end
      end

      def execute_inline_ruby!
        return unless site.config.should_execute_inline_ruby?

        Bridgetown::Utils::RubyExec.search_data_for_ruby_code(resource)
      end

      def inspect
        "#<#{self.class} Conversion Steps: #{conversions.length}>"
      end

      private

      ### Utilities

      def permalink_ext
        resource_permalink = resource.permalink
        if resource_permalink &&
            !resource_permalink.end_with?("/") &&
            !resource_permalink.end_with?(".*")
          permalink_ext = File.extname(resource_permalink)
          permalink_ext unless permalink_ext.empty?
        end
      end

      # @return [Array<Bridgetown::Converter>]
      def converters
        @converters ||= site.matched_converters_for_convertible(resource)
      end

      # @return [String]
      def output_ext_from_converters
        @conversions = converters.map do |converter|
          {
            converter:,
            output_ext: converter.output_ext(resource.extname),
          }
        end

        conversions
          .reverse
          .find do |conversion|
            conversions.length == 1 ||
              !conversion[:converter].is_a?(Bridgetown::Converters::Identity)
          end
          .fetch(:output_ext)
      end

      def place_into_layouts
        Bridgetown.logger.debug "Placing in Layouts:", resource.relative_path
        output = resource.content.dup
        site.validated_layouts_for(resource, resource.data.layout).each do |layout|
          output = transform_with_layout(layout, output, resource) do |converter, layout_output|
            conversions << {
              type: :layout,
              layout:,
              converter:,
              output: Bridgetown.env.production? ? nil : layout_output,
            }
          end
        end
        resource.output = output
      end
    end
  end
end

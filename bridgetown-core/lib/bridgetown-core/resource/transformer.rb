# frozen_string_literal: true

module Bridgetown
  module Resource
    class Transformer
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

      def process!
        Bridgetown.logger.debug "Transforming:", resource.relative_path
        resource.around_hook :render do
          execute_inline_ruby
          run_conversions
          place_into_layouts if resource.place_in_layout?
          set_output_ext
        end
      end

      def inspect
        "#<#{self.class} Conversion Steps: #{conversions.length}>"
      end

      private

      # @return [Array<Bridgetown::Converter>]
      def converters
        @converters ||= site.matched_converters_for_convertible(resource)
      end

      def validated_layouts
        layout = site.layouts[resource.data.layout]
        warn_on_missing_layout layout, resource.data.layout

        layout_list = Set.new([layout])
        while layout
          layout_name = layout.data.layout
          layout = site.layouts[layout_name]
          warn_on_missing_layout layout, layout_name

          layout_list << layout
        end

        layout_list.to_a.compact
      end

      def warn_on_missing_layout(layout, layout_name)
        if layout.nil? && layout_name
          Bridgetown.logger.warn "Build Warning:", "Layout '#{layout_name}' " \
          "requested via #{resource.relative_path} does not exist."
        end
      end

      def execute_inline_ruby
        return unless site.config.should_execute_inline_ruby?

        Bridgetown::Utils::RubyExec.search_data_for_ruby_code(resource, self)
      end

      def run_conversions
        input = resource.content.to_s

        # @param content [String]
        # @param converter [Bridgetown::Converter]
        resource.content = converters.inject(input) do |content, converter|
          output = if converter.method(:convert).arity == 1
                     converter.convert content
                   else
                     converter.convert content, resource
                   end
          conversions << {
            type: :content,
            converter: converter,
            output: Bridgetown.env.production? ? nil : output,
            output_ext: converter.output_ext(resource.extname),
          }
          output
        rescue StandardError => e
          Bridgetown.logger.error "Conversion error:",
                                  "#{converter.class} encountered an error while "\
                                  "converting `#{resource.relative_path}'"
          raise e
        end
      end

      def place_into_layouts
        Bridgetown.logger.debug "Placing in Layouts:", resource.relative_path
        output = resource.content.dup
        validated_layouts.each do |layout|
          output = run_layout_conversions layout, output
        end
        resource.output = output
      end

      def run_layout_conversions(layout, output)
        layout_converters = site.matched_converters_for_convertible(layout)
        layout_input = layout.content.dup

        layout_converters.inject(layout_input) do |content, converter|
          next(content) unless converter.method(:convert).arity == 2

          layout.current_document = resource
          layout.current_document_output = output
          layout_output = converter.convert content, layout

          conversions << {
            type: :layout,
            layout: layout,
            converter: converter,
            output: Bridgetown.env.production? ? nil : layout_output,
          }
          layout_output
        rescue StandardError => e
          Bridgetown.logger.error "Conversion error:",
                                  "#{converter.class} encountered an error while "\
                                  "converting `#{resource.relative_path}'"
          raise e
        end
      end

      def set_output_ext
        if resource.destination
          output_ext = (permalink_ext || output_ext_from_converters)
          resource.destination.output_ext = output_ext
        end
      end

      def permalink_ext
        resource_permalink = resource.permalink
        if resource_permalink &&
            !resource_permalink.end_with?("/") &&
            !resource_permalink.end_with?(".*")
          permalink_ext = File.extname(resource_permalink)
          permalink_ext unless permalink_ext.empty?
        end
      end

      def output_ext_from_converters
        conversions
          .reverse.find do |conversion|
            conversion[:type] == :content &&
              (
                conversions.length == 1 ||
                !conversion[:converter].is_a?(Bridgetown::Converters::Identity)
              )
          end
          &.fetch(:output_ext)
      end
    end
  end
end

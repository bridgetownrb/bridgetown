# frozen_string_literal: true

module Bridgetown
  class Converter < Plugin
    class << self
      attr_accessor :extname_list

      # Converters can provide one or more extensions they accept. Examples:
      #
      # * `input :erb`
      # * `input %i(xls xlsx)`
      def input(extnames)
        extnames = Array(extnames)
        self.extname_list ||= []
        self.extname_list += extnames.map { |e| ".#{e.to_s.downcase}" }
      end

      def supports_slots?
        @support_slots == true
      end

      def support_slots(bool = true) # rubocop:disable Style/OptionalBooleanParameter
        @support_slots = bool == true
      end
    end

    # Initialize the converter.
    #
    # Returns an initialized Converter.
    def initialize(config = {})
      super
      @config = config
    end

    # Logic to do the content conversion.
    #
    # @param content [String] content of file (without front matter).
    # @param convertible [Bridgetown::Layout, Bridgetown::Resource::Base]
    #
    # @return [String] the converted content.
    def convert(content, convertible = nil) # rubocop:disable Lint/UnusedMethodArgument
      content
    end

    # Does the given extension match this converter's list of acceptable extensions?
    #
    # @param [String] ext
    #   The file's extension (including the dot)
    #
    # @return [Boolean] Whether the extension matches one in the list
    def matches(ext)
      (self.class.extname_list || []).include?(ext.downcase)
    end

    # You can override this in Converter subclasses as needed. Default is ".html"
    #
    # @param [String] ext
    #   The extension of the original file
    #
    # @return [String] The output file extension (including the dot)
    def output_ext(_ext)
      ".html"
    end

    def line_start(convertible)
      if convertible.is_a?(Bridgetown::Resource::Base) &&
          convertible.model.origin.respond_to?(:front_matter_line_count)
        convertible.model.origin.front_matter_line_count + 4
      elsif convertible.is_a?(Bridgetown::GeneratedPage) && convertible.original_resource
        res = convertible.original_resource
        if res.model.origin.respond_to?(:front_matter_line_count)
          res.model.origin.front_matter_line_count + 4
        else
          1
        end
      else
        1
      end
    end

    def inspect
      "#<#{self.class}#{self.class.extname_list ? " #{self.class.extname_list.join(", ")}" : nil}>"
    end
  end
end

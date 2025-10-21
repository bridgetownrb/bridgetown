# frozen_string_literal: true

module Bridgetown
  class Converter < Plugin
    class << self
      attr_accessor :extname_list

      # Converters can provide one or more extensions they accept. Examples:
      #
      # * `input :erb`
      # * `input %i(xls xlsx)`
      #
      # @param extnames [Array<Symbol>] extensions
      def input(extnames)
        extnames = Array(extnames)
        self.extname_list ||= []
        self.extname_list += extnames.map { |e| ".#{e.to_s.downcase}" }
      end

      # Set or return the delimiters used for helper calls in template code
      # (e.g. `["<%=", "%>"]` for ERB). This is purely informational for the framework's benefit,
      # not used within a rendering pipeline.
      #
      # @param delimiters [Array<String>] delimiters
      def helper_delimiters(delimiters = nil)
        return @helper_delimiters if delimiters.nil?

        @helper_delimiters = delimiters
      end

      def supports_slots? = @support_slots

      def support_slots(bool = true) # rubocop:disable Style/OptionalBooleanParameter
        @support_slots = bool == true
      end

      def template_engine(name = nil)
        return @template_engine unless name

        @template_engine = name.to_s
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
    # @return [String] the converted content.
    def convert(content, convertible = nil) # rubocop:disable Lint/UnusedMethodArgument
      content
    end

    # Does the given extension match this converter's list of acceptable extensions?
    #
    # @param ext [String] the file's extension (including the dot)
    # @param convertible [Bridgetown::Layout, Bridgetown::Resource::Base]
    # @return [Boolean] Whether the extension matches one in the list
    def matches(ext, _convertible = nil)
      (self.class.extname_list || []).include?(ext.downcase)
    end

    def determine_template_engine(convertible)
      template_engine = self.class.template_engine
      convertible_engine = convertible.data["template_engine"].to_s
      convertible_engine == template_engine ||
        (convertible_engine == "" && @config["template_engine"].to_s == template_engine)
    end

    # You can override this in Converter subclasses as needed. Default is ".html", unless the
    # converter is a template engine and the input file doesn't match the normal template extension
    #
    # @param ext [String] the extension of the original file
    # @return [String] The output file extension (including the dot)
    def output_ext(ext)
      if self.class.template_engine
        (self.class.extname_list || []).include?(ext.downcase) ? ".html" : ext
      else
        ".html"
      end
    end

    def line_start(convertible) # rubocop:disable Metrics/CyclomaticComplexity
      fmlc = case convertible
             when Bridgetown::Layout
               convertible.front_matter_line_count
             when Bridgetown::Resource::Base
               convertible.model.origin.respond_to?(:front_matter_line_count) &&
                 convertible.model.origin.front_matter_line_count
             when Bridgetown::GeneratedPage
               res = convertible.original_resource
               if res&.model&.origin.respond_to?(:front_matter_line_count)
                 res.model.origin.front_matter_line_count
               end
             end

      if fmlc
        # We add 4 because the line counts are only for the interior of the front matter and we need
        # to include 2 more lines for the delimiters, plus a blank line, plus 1 to get to content
        #
        # That shorthand breaks down if someone authors *no* blank line after front matter, or if
        # there are multiple blank lines. But those are not best practices, so we'll just fudge it.
        fmlc + 4
      else
        1
      end
    end

    def inspect
      "#<#{self.class}#{self.class.extname_list ? " #{self.class.extname_list.join(", ")}" : nil}>"
    end
  end
end

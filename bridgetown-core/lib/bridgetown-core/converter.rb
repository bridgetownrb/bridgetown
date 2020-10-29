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
    end

    # Initialize the converter.
    #
    # Returns an initialized Converter.
    def initialize(config = {})
      @config = config
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
  end
end

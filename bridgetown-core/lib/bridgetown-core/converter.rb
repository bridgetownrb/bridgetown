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

    # Public: Get or set the highlighter prefix. When an argument is specified,
    # the prefix will be set. If no argument is specified, the current prefix
    # will be returned.
    #
    # highlighter_prefix - The String prefix (default: nil).
    #
    # Returns the String prefix.
    def self.highlighter_prefix(highlighter_prefix = nil)
      unless defined?(@highlighter_prefix) && highlighter_prefix.nil?
        @highlighter_prefix = highlighter_prefix
      end
      @highlighter_prefix
    end

    # Public: Get or set the highlighter suffix. When an argument is specified,
    # the suffix will be set. If no argument is specified, the current suffix
    # will be returned.
    #
    # highlighter_suffix - The String suffix (default: nil).
    #
    # Returns the String suffix.
    def self.highlighter_suffix(highlighter_suffix = nil)
      unless defined?(@highlighter_suffix) && highlighter_suffix.nil?
        @highlighter_suffix = highlighter_suffix
      end
      @highlighter_suffix
    end

    # Initialize the converter.
    #
    # Returns an initialized Converter.
    def initialize(config = {})
      @config = config
    end

    # Override in Converter subclasses.
    # Does the given extension match this converter's list of acceptable extensions?
    # Takes one argument: the file's extension (including the dot).
    #
    # ext - The String extension to check
    #
    # Returns true since it always matches.
    def matches(ext)
      (self.class.extname_list || []).include?(ext.downcase)
    end

    # Override in Converter subclasses.
    # The extension to be given to the output file (including the dot).
    #
    # ext - The String extension or original file.
    #
    # Returns The String output file extension.
    def output_ext(_ext)
      ".html"
    end

    # Get the highlighter prefix.
    #
    # Returns the String prefix.
    def highlighter_prefix
      self.class.highlighter_prefix
    end

    # Get the highlighter suffix.
    #
    # Returns the String suffix.
    def highlighter_suffix
      self.class.highlighter_suffix
    end
  end
end

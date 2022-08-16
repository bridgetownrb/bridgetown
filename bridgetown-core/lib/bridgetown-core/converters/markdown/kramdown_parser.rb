# frozen_string_literal: true

module Kramdown
  # A Kramdown::Document subclass meant to optimize memory usage from initializing
  # a kramdown document for parsing.
  #
  # The optimization is by using the same options Hash (and its derivatives) for
  # converting all Markdown documents in a Bridgetown site.
  class BridgetownDocument < Document
    class << self
      attr_reader :options, :parser

      # The implementation is basically the core logic in +Kramdown::Document#initialize+
      def setup(options)
        @cache ||= {}

        # reset variables on a subsequent set up with a different options Hash
        unless @cache[:id] == options.hash
          @options = @parser = nil
          @cache[:id] = options.hash
        end

        @options ||= Options.merge(options).freeze
        @parser  ||= begin
          parser_name = (@options[:input] || "kramdown").to_s
          parser_name = parser_name[0..0].upcase + parser_name[1..]
          try_require("parser", parser_name)

          if Parser.const_defined?(parser_name)
            Parser.const_get(parser_name)
          else
            raise Kramdown::Error, "kramdown has no parser to handle the specified " \
                                   "input format: #{@options[:input]}"
          end
        end
      end

      private

      def try_require(type, name)
        require "kramdown/#{type}/#{Utils.snake_case(name)}"
      rescue LoadError
        false
      end
    end

    def initialize(source, options = {}) # rubocop:disable Lint/MissingSuper
      BridgetownDocument.setup(options)

      @options = BridgetownDocument.options
      @root, @warnings = BridgetownDocument.parser.parse(source, @options)
    end

    # Use Kramdown::Converter::Html class to convert this document into HTML.
    #
    # The implementation is basically an optimized version of core logic in
    # +Kramdown::Document#method_missing+ from kramdown-2.1.0.
    def to_html
      output, warnings = Kramdown::Converter::Html.convert(@root, @options)
      @warnings.concat(warnings)
      output
    end
  end
end

#

module Bridgetown
  module Converters
    class Markdown
      class KramdownParser
        attr_reader :extractions

        def initialize(config)
          @config = config["kramdown"] || {}
          @config["syntax_highlighter"] ||= config["highlighter"] || "rouge"
          @config["syntax_highlighter_opts"] ||= {}
          @config["syntax_highlighter_opts"]["guess_lang"] = @config["guess_lang"]
          require_relative "../../kramdown/parser/gfm" if @config["input"] == "GFM"
        end

        def convert(content)
          document = Kramdown::BridgetownDocument.new(content, @config)
          html_output = document.to_html
          if @config["show_warnings"]
            document.warnings.each do |warning|
              Bridgetown.logger.warn "Kramdown warning:", warning
            end
          end
          @extractions = document.root.options[:extractions] # could be nil
          html_output
        end
      end
    end
  end
end

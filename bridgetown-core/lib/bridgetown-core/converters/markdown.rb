# frozen_string_literal: true

module Bridgetown
  module Converters
    # Markdown converter.
    # For more info on converters see https://bridgetownrb.com/docs/plugins/converters/
    class Markdown < Converter
      support_slots

      def initialize(config = {})
        super

        self.class.input @config["markdown_ext"].split(",")
      end

      def setup
        return if @setup ||= false

        unless (@parser = get_processor)
          Bridgetown.logger.error "Markdown processor:", "#{@config["markdown"].inspect} \
                                  is not a valid Markdown processor."
          Bridgetown.logger.error "", "Available processors are: #{valid_processors.join(", ")}"
          Bridgetown.logger.error ""
          raise Errors::FatalException, "Invalid Markdown processor given: #{@config["markdown"]}"
        end

        unless @config.cache_markdown == false || @config.kramdown.input == "GFMExtractions"
          @cache = Bridgetown::Cache.new("Bridgetown::Converters::Markdown")
        end
        @setup = true
      end

      # RuboCop does not allow reader methods to have names starting with `get_`
      # To ensure compatibility, this check has been disabled on this method
      #
      # rubocop:disable Naming/AccessorMethodName
      def get_processor
        case @config["markdown"].downcase
        when "kramdown" then KramdownParser.new(@config)
        else
          custom_processor
        end
      end
      # rubocop:enable Naming/AccessorMethodName

      # Provides you with a list of processors comprised of the ones we support internally
      # and the ones that you have provided to us
      #
      # @return [Array<Symbol>]
      def valid_processors
        [:kramdown] + third_party_processors
      end

      # A list of processors that you provide via plugins
      #
      # @return [Array<Symbol>]
      def third_party_processors
        self.class.constants - [:KramdownParser, :PRIORITIES]
      end

      # Logic to do the content conversion
      #
      # @param content [String] content of file (without front matter)
      # @return [String] converted content
      def convert(content, convertible = nil)
        setup
        if @cache
          @cache.getset(content) do
            @parser.convert(content)
          end
        else
          output = @parser.convert(content)
          if convertible && @parser.respond_to?(:extractions)
            convertible.data.markdown_extractions = @parser.extractions
          end
          output
        end
      end

      private

      def custom_processor
        converter_name = @config["markdown"]
        self.class.const_get(converter_name).new(@config) if custom_class_allowed?(converter_name)
      end

      # Determine whether a class name is an allowed custom markdown class name.
      #
      # @param parser_name [Symbol] name of the parser class
      # @return [Boolean] true if the parser name contains only alphanumeric characters and is defined
      #   within `Bridgetown::Converters::Markdown`
      def custom_class_allowed?(parser_name)
        parser_name !~ %r![^A-Za-z0-9_]! && self.class.constants.include?(parser_name.to_sym)
      end
    end
  end
end

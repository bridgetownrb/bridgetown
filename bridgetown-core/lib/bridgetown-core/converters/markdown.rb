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

      # Public: Provides you with a list of processors comprised of the ones we support internally
      # and the ones that you have provided to us
      #
      # Returns an array of symbols.
      def valid_processors
        [:kramdown] + third_party_processors
      end

      # Public: A list of processors that you provide via plugins.
      #
      # Returns an array of symbols
      def third_party_processors
        self.class.constants - [:KramdownParser, :PRIORITIES]
      end

      # Logic to do the content conversion.
      #
      # content - String content of file (without front matter).
      #
      # Returns a String of the converted content.
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

      # Private: Determine whether a class name is an allowed custom
      #   markdown class name.
      #
      # parser_name - the name of the parser class
      #
      # Returns true if the parser name contains only alphanumeric characters and is defined
      # within Bridgetown::Converters::Markdown
      def custom_class_allowed?(parser_name)
        parser_name !~ %r![^A-Za-z0-9_]! && self.class.constants.include?(parser_name.to_sym)
      end
    end
  end
end

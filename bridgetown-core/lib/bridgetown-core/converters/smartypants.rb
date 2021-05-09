# frozen_string_literal: true

module Kramdown
  module Parser
    class SmartyPants < Kramdown::Parser::Kramdown
      def initialize(source, options)
        super
        @block_parsers = [:block_html, :content]
        @span_parsers =  [:smart_quotes, :html_entity, :typographic_syms, :span_html]
      end

      def parse_content
        add_text @src.scan(%r!\A.*\n!)
      end
      define_parser(:content, %r!\A!)
    end
  end
end

module Bridgetown
  module Converters
    # SmartyPants converter.
    # For more info on converters see https://bridgetownrb.com/docs/plugins/converters/
    class SmartyPants < Converter
      priority :low

      def initialize(config)
        unless defined?(Kramdown)
          Bridgetown::Utils::RequireGems.require_with_graceful_fail "kramdown"
        end
        @config = config["kramdown"].dup || {}
        @config[:input] = :SmartyPants
      end

      # Public: The extension to be given to the output file (including the dot).
      #
      # ext - The String extension or original file.
      #
      # Returns The String output file extension.
      def output_ext(_ext)
        nil
      end

      # Logic to do the content conversion.
      #
      # content - String content of file (without front matter).
      #
      # Returns a String of the converted content.
      def convert(content)
        document = Kramdown::Document.new(content, @config)
        html_output = document.to_html.chomp
        if @config["show_warnings"]
          document.warnings.each do |warning|
            Bridgetown.logger.warn "Kramdown warning:", warning.sub(%r!^Warning:\s+!, "")
          end
        end
        html_output
      end
    end
  end
end

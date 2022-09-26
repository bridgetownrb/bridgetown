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
  module Utils
    class SmartyPantsConverter
      # @param config [Bridgetown::Configuration]
      def initialize(config)
        @config = config["kramdown"].dup || {}
        @config[:input] = :SmartyPants
      end

      # @param content [String]
      # @return String
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

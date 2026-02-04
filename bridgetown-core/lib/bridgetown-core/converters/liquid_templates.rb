# frozen_string_literal: true

module Bridgetown
  module Converters
    class LiquidTemplates < Converter
      priority :highest
      input :liquid
      template_engine :liquid
      helper_delimiters ["{%", "%}"]

      attr_reader :site, :document, :layout

      class << self
        attr_accessor :cached_partials
      end

      # rubocop: disable Metrics/AbcSize
      # rubocop: disable Metrics/MethodLength

      # Logic to do the Liquid content conversion.
      #
      # @param content [String] Content of the file (without front matter).
      # @param convertible [
      #   Bridgetown::GeneratedPage, Bridgetown::Resource::Base, Bridgetown::Layout]
      #   The instantiated object which is processing the file.
      # @return [String] The converted content.
      def convert(content, convertible)
        self.class.cached_partials ||= {}
        @payload = nil

        @site = convertible.site
        if convertible.is_a?(Bridgetown::Layout)
          @document = convertible.current_document
          @layout = convertible
          configure_payload(layout.current_document_output)
        else
          @document = convertible
          @layout = site.layouts[document.data["layout"]]
          configure_payload
        end

        template = site.liquid_renderer.file(convertible.path).parse(content)
        template.warnings.each do |e|
          Bridgetown.logger.warn "Liquid Warning:",
                                 LiquidRenderer.format_error(e, convertible.path)
        end
        template.render!(payload, liquid_context)
      # rubocop: disable Lint/RescueException
      rescue Exception => e
        Bridgetown.logger.error "Liquid Exception:",
                                LiquidRenderer.format_error(e, convertible.path)
        raise e
      end
      # rubocop: enable Lint/RescueException
      # rubocop: enable Metrics/MethodLength
      # rubocop: enable Metrics/AbcSize

      # Fetches the payload used in Liquid rendering, aka `site.site_payload`
      #
      # @return [Bridgetown::Drops::UnifiedPayloadDrop]
      def payload
        @payload ||= site.site_payload
      end

      # Set page content to payload and assign paginator if document has one.
      #
      # @return [void]
      def configure_payload(content = nil)
        payload["page"] = document.to_liquid
        payload["paginator"] = document.respond_to?(:paginator) ? document.paginator.to_liquid : nil
        payload["layout"] = @layout ? @layout.to_liquid.merge({ data: @layout.data }) : {}
        payload["content"] = content
        payload["data"] = payload["page"].data
      end

      def liquid_context
        {
          registers: {
            site:,
            page: payload["page"],
            cached_partials: self.class.cached_partials,
            resource: document,
          },
          strict_filters: site.config["liquid"]["strict_filters"],
          strict_variables: site.config["liquid"]["strict_variables"],
        }
      end
    end
  end
end

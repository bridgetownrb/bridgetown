# frozen_string_literal: true

module Bridgetown
  module Builders
    module DSL
      module Inspectors
        # Add a couple familar DOM API features
        module QuerySelection
          def query_selector(selector)
            css(selector).first
          end

          def query_selector_all(selector)
            css(selector)
          end
        end

        # HTML inspector type
        module HTML
          # Are there inspectors available? Is it an .htm* file?
          def self.can_run?(resource, inspectors)
            inspectors &&
              resource.destination&.output_ext&.starts_with?(".htm") &&
              !resource.data.bypass_inspectors
          end

          # Process the resource with the available inspectors and return the output HTML
          #
          # @return [String] transformed HTML
          def self.call(resource, inspectors)
            doc = Nokogiri.HTML5(resource.output)

            inspectors.each do |block|
              block.call(doc, resource)
            end

            doc.to_html
          end
        end

        # XML inspector type
        module XML
          # Strip the resource's initial extension dot. `.rss` => `rss`
          def self.resource_ext(resource)
            resource.destination&.output_ext&.delete_prefix(".")
          end

          # Are there any inspectors available which match the resource extension?
          def self.can_run?(resource, inspectors)
            inspectors &&
              inspectors[resource_ext(resource)] &&
              !resource.data.bypass_inspectors
          end

          # Process the resource with the available inspectors and return the output XML
          #
          # @return [String] transformed XML
          def self.call(resource, inspectors)
            doc = Nokogiri::XML(resource.output)

            inspectors[resource_ext(resource)].each do |block|
              block.call(doc, resource)
            end

            doc.to_xml
          end
        end

        class << self
          # Require the Nokogiri gem if necessary and add the `QuerySelection` mixin
          def setup_nokogiri
            unless defined?(Nokogiri)
              Bridgetown::Utils::RequireGems.require_with_graceful_fail "nokogiri"
            end

            return if Nokogiri::XML::Node <= QuerySelection

            Nokogiri::XML::Node.include QuerySelection
          end

          # Shorthand for `HTML.call`
          def process_html(...)
            HTML.call(...)
          end

          # Shorthand for `XML.call`
          def process_xml(...)
            XML.call(...)
          end
        end

        # Set up an inspector to review or manipulate HTML resources
        # @yield the block to be called after the resource has been rendered
        # @yieldparam [Nokogiri::HTML5::Document] the Nokogiri document
        def inspect_html(&block)
          unless @_html_inspectors
            @_html_inspectors = []

            Inspectors.setup_nokogiri

            hook :resources, :post_render do |resource|
              next unless HTML.can_run?(resource, @_html_inspectors)

              resource.output = Inspectors.process_html(resource, @_html_inspectors)
            end
          end

          @_html_inspectors << block
        end

        # Set up an inspector to review or manipulate XML resources
        # @param extension [String] defaults to `xml`
        # @yield the block to be called after the resource has been rendered
        # @yieldparam [Nokogiri::XML::Document] the Nokogiri document
        def inspect_xml(extension = "xml", &block)
          unless @_xml_inspectors
            @_xml_inspectors = {}

            Inspectors.setup_nokogiri

            hook :resources, :post_render do |resource|
              next unless Inspectors::XML.can_run?(resource, @_xml_inspectors)

              resource.output = Inspectors.process_xml(resource, @_xml_inspectors)
            end
          end

          (@_xml_inspectors[extension.to_s] ||= []).tap do |arr|
            arr << block
          end

          @_xml_inspectors
        end
      end
    end
  end
end

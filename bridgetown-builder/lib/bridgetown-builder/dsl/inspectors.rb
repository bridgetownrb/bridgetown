# frozen_string_literal: true

module Bridgetown
  module Builders
    module DSL
      module Inspectors
        # Add a couple familar DOM API features
        module QuerySelection
          def query_selector(selector)
            at_css(selector)
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
              resource.output_ext&.starts_with?(".htm") &&
              !resource.data.bypass_inspectors
          end

          # Process the resource with the available inspectors and return the output HTML
          #
          # @return [String] transformed HTML
          def self.call(resource, inspectors)
            doc = if resource.site.config.html_inspector_parser == "nokolexbor"
                    Nokolexbor::HTML(resource.output)
                  else
                    Nokogiri.HTML5(resource.output)
                  end

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
            resource.output_ext&.delete_prefix(".")
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

            Nokogiri::XML::Node.include QuerySelection unless Nokogiri::XML::Node <= QuerySelection
          end

          # Require the Nokolexbor gem if necessary and add the `QuerySelection` mixin
          def setup_nokolexbor
            unless defined?(Nokolexbor)
              Bridgetown::Utils::RequireGems.require_with_graceful_fail "nokolexbor"
            end

            Nokolexbor::Node.include QuerySelection unless Nokolexbor::Node <= QuerySelection
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
        # @yieldparam [Nokogiri::HTML5::Document, Nokolexbor::Document]
        #   the Nokogiri or Nokolexbor document
        def inspect_html(&block)
          unless @_html_inspectors
            @_html_inspectors = []

            if site.config.html_inspector_parser == "nokolexbor"
              Inspectors.setup_nokolexbor
            else
              Inspectors.setup_nokogiri
            end

            hook :resources, :post_render do |resource|
              next unless HTML.can_run?(resource, @_html_inspectors)

              resource.output = Inspectors.process_html(resource, @_html_inspectors)
            end

            hook :generated_pages, :post_render do |page|
              next unless HTML.can_run?(page, @_html_inspectors)

              page.output = Inspectors.process_html(page, @_html_inspectors)
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

            hook :generated_pages, :post_render do |page|
              next unless Inspectors::XML.can_run?(page, @_xml_inspectors)

              page.output = Inspectors.process_xml(page, @_xml_inspectors)
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

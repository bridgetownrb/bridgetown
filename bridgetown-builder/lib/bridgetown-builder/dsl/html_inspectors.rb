# frozen_string_literal: true

module Bridgetown
  module Builders
    module DSL
      module HtmlInspectors
        module QuerySelection
          def query_selector(selector)
            css(selector).first
          end

          def query_selector_all(selector)
            css(selector)
          end
        end

        module RunInspectors
          def self.call(resource, inspectors) # rubocop:disable Metrics/CyclomaticComplexity
            return resource.output if !inspectors ||
              !resource.destination&.output_ext&.starts_with?(".htm") ||
              resource.data.bypass_html_inspectors

            doc = Nokogiri.HTML5(resource.output)

            inspectors&.each do |block|
              block.call(doc)
            end

            doc.to_html
          end
        end

        def inspect_html(&block)
          unless @_inspectors
            unless defined?(Nokogiri)
              Bridgetown::Utils::RequireGems.require_with_graceful_fail "nokogiri"
            end
            Nokogiri::XML::Node.include QuerySelection unless Nokogiri::XML::Node <= QuerySelection

            hook :resources, :post_render do |resource|
              resource.output = RunInspectors.call(resource, @_inspectors)
            end
          end

          @_inspectors ||= []
          @_inspectors << block
        end
      end
    end
  end
end

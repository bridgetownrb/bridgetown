# frozen_string_literal: true

module Bridgetown
  module Transformable
    # Transforms an input document by running it through available converters
    # (requires a `converter` method to be present on the including class)
    #
    # @param document [Bridgetown::GeneratedPage, Bridgetown::Resource::Base]
    # @param alternate_content [String, nil] Pass in content if you don't want to use document's
    # @return String
    # @yieldparam converter [Bridgetown::Converter]
    # @yieldparam index [Integer] index of the conversion step
    # @yieldparam output [String]
    def transform_content(document, alternate_content: nil)
      converters.each_with_index.inject(
        (alternate_content || document.content).to_s
      ) do |content, (converter, index)|
        output = if converter.method(:convert).arity == 1
                   converter.convert content
                 else
                   converter.convert content, document
                 end

        yield converter, index, output if block_given?

        output.html_safe
      rescue StandardError => e
        Bridgetown.logger.error "Conversion error:",
                                "#{converter.class} encountered an error while " \
                                "converting `#{document.relative_path}'"
        raise e
      end
    end

    # Transforms an input document by placing it within the specified layout
    #
    # @param layout [Bridgetown::Layout]
    # @param output [String] the output from document content conversions
    # @param document [Bridgetown::GeneratedPage, Bridgetown::Resource::Base]
    # @return String
    # @yieldparam converter [Bridgetown::Converter]
    # @yieldparam layout_output [String]
    def transform_with_layout(layout, output, document)
      layout_converters = site.matched_converters_for_convertible(layout)
      layout_input = layout.content.dup

      layout_converters.inject(layout_input) do |content, converter|
        next(content) unless [2, -2].include?(converter.method(:convert).arity) # rubocop:disable Performance/CollectionLiteralInLoop

        layout.current_document = document
        layout.current_document_output = output
        layout_output = converter.convert content, layout

        yield converter, layout_output if block_given?

        layout_output
      rescue StandardError => e
        Bridgetown.logger.error "Conversion error:",
                                "#{converter.class} encountered an error while " \
                                "converting `#{document.relative_path}'"
        raise e
      end
    end
  end
end

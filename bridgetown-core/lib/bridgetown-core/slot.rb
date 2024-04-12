# frozen_string_literal: true

module Bridgetown
  class Slot
    include Transformable

    # @return [String]
    attr_reader :name

    # @return [String]
    attr_accessor :content

    # @return [Object, nil]
    attr_reader :context

    def initialize(name:, content:, context:, transform: false)
      @name, @content, @context = name, content, context

      Bridgetown::Hooks.trigger :slots, :pre_render, self
      transform! if transform
      Bridgetown::Hooks.trigger :slots, :post_render, self
    end

    def transform!
      self.content = transform_content(context, alternate_content: content)
    end

    private

    def converters
      # A private method calling another private method. Hmm.
      document_converters = context.is_a?(Bridgetown::Resource::Base) ?
                              context.transformer.send(:converters) :
                              context.send(:converters)

      document_converters.select { _1.class.supports_slots? }
    end
  end
end

# frozen_string_literal: true

module Bridgetown
  module Utils
    module RubyExec
      extend self

      # Sets up a new context in which to eval Ruby coming from front matter.
      #
      # ruby_code - a string of code
      # document - the Document with the Ruby front matter
      # renderer - the Renderer instance that's processing the document
      #
      # Returns the transformed output of the code
      def run(ruby_code, document, renderer)
        return unless ruby_code.is_a?(Rb)

        klass = Class.new
        klass.attr_accessor :document, :page, :renderer, :site
        obj = klass.new
        obj.document = obj.page = document
        obj.renderer = renderer
        obj.site = document.site

        # This is where the magic happens! DON'T BE EVIL!!! ;-)
        output = obj.instance_eval(ruby_code)

        output = Bridgetown::Utils.stringify_hash_keys(output) if output.is_a?(Hash)

        output
      end
    end
  end
end

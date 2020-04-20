# frozen_string_literal: true

module Bridgetown
  module Utils
    module RubyExec
      extend self

      # Sets up a new context in which to eval Ruby coming from front matter.
      #
      # ruby_code - a string of code
      # convertible - the Document/Page/Layout with the Ruby front matter
      # renderer - the Renderer instance that's processing the document (optional)
      #
      # Returns the transformed output of the code
      def run(ruby_code, convertible, renderer)
        return unless ruby_code.is_a?(Rb)

        klass = Class.new
        obj = klass.new

        if convertible.is_a?(Layout)
          klass.attr_accessor :layout, :site
          obj.layout = convertible
        else
          klass.attr_accessor :document, :page, :renderer, :site
          obj.document = obj.page = convertible
          obj.renderer = renderer
        end
        obj.site = convertible.site

        # This is where the magic happens! DON'T BE EVIL!!! ;-)
        output = obj.instance_eval(ruby_code)

        output = Bridgetown::Utils.stringify_hash_keys(output) if output.is_a?(Hash)

        output
      end
    end
  end
end

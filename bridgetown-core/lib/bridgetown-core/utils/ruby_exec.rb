# frozen_string_literal: true

module Bridgetown
  module Utils
    module RubyExec
      extend self

      # rubocop:disable Metrics/AbcSize
      def search_data_for_ruby_code(convertible, renderer)
        return if convertible.data.empty?

        # Iterate using `keys` here so inline Ruby script can add new data keys
        # if necessary without an error
        data_keys = convertible.data.keys
        data_keys.each do |k|
          v = convertible.data[k]
          next unless v.is_a?(Rb) || v.is_a?(Hash)

          if v.is_a?(Hash)
            v.each do |nested_k, nested_v|
              next unless nested_v.is_a?(Rb)

              Bridgetown.logger.warn("Executing inline Ruby…", convertible.relative_path)
              convertible.data[k][nested_k] = run(nested_v, convertible, renderer)
              Bridgetown.logger.warn("Inline Ruby completed!", convertible.relative_path)
            end
          else
            Bridgetown.logger.warn("Executing inline Ruby…", convertible.relative_path)
            convertible.data[k] = run(v, convertible, renderer)
            Bridgetown.logger.warn("Inline Ruby completed!", convertible.relative_path)
          end
        end
      end
      # rubocop:enable Metrics/AbcSize

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
          klass.attr_accessor :layout, :site, :data
          obj.layout = convertible
        else
          klass.attr_accessor :document, :page, :renderer, :site, :data
          obj.document = obj.page = convertible
          obj.renderer = renderer
        end
        obj.site = convertible.site
        obj.data = convertible.data

        # This is where the magic happens! DON'T BE EVIL!!! ;-)
        output = obj.instance_eval(ruby_code)

        output = Bridgetown::Utils.stringify_hash_keys(output) if output.is_a?(Hash)

        output
      end
    end
  end
end

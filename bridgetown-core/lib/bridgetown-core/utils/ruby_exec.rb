# frozen_string_literal: true

module Bridgetown
  module Utils
    module RubyExec
      def self.search_data_for_ruby_code(convertible)
        return if convertible.data.empty?

        # Iterate using `keys` here so inline Ruby script can add new data keys
        # if necessary without an error
        data_keys = convertible.data.keys
        data_keys.each do |k|
          v = convertible.data[k]
          next unless v.is_a?(Proc)

          convertible.data[k] = convertible.instance_exec(&v)
        end
      end
    end
  end
end

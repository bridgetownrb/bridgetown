# frozen_string_literal: true

module Bridgetown
  module Utils
    module RubyExec
      # @param context [Layout, Model::RepoOrigin] the execution context (i.e.
      #   `self` for the Ruby code)
      # @param ruby_code [String] the Ruby code to execute
      # @param file_path [String] the absolute path to the file
      # @param starting_line [Integer] the number to list as the starting line
      #   for compilation errors
      # @return [Hash]
      def self.process_ruby_data(context, ruby_code, file_path, starting_line)
        ruby_data = context.instance_eval(ruby_code, file_path.to_s, starting_line)
        ruby_data.is_a?(Array) ? { rows: ruby_data } : ruby_data.to_h
      rescue StandardError => e
        raise(
          "Ruby code isn't returning an array, or object which " \
          "responds to `to_h' (#{e.message})"
        )
      end

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

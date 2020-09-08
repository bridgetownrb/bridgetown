# frozen_string_literal: true

module Bridgetown
  class DefaultsReader
    attr_reader :site, :path_defaults

    def initialize(site)
      @site = site
      @path_defaults = ActiveSupport::HashWithIndifferentAccess.new
    end

    def read
      entries = Dir.chdir(site.in_source_dir) do
        Dir["**/_defaults.{yaml,yml,json}"]
      end

      entries.each do |entry|
        path = @site.in_source_dir(entry)
        @path_defaults[File.dirname(path) + File::SEPARATOR] = SafeYAML.load_file(path)
      end

      @path_defaults
    end
  end
end

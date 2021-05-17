# frozen_string_literal: true

module Bridgetown
  class DefaultsReader
    attr_reader :site, :path_defaults

    def initialize(site)
      @site = site
      @path_defaults = HashWithDotAccess::Hash.new
    end

    def read
      return unless File.directory?(site.source)

      entries = Dir.chdir(site.source) do
        Dir["**/_defaults.{yaml,yml,json}"]
      end

      entries.each do |entry|
        path = @site.in_source_dir(entry)
        @path_defaults[File.dirname(path) + File::SEPARATOR] = YAMLParser.load_file(path)
      end

      @path_defaults
    end
  end
end

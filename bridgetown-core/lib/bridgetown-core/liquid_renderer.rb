# frozen_string_literal: true

require_relative "liquid_renderer/file_system"
require_relative "liquid_renderer/file"
require_relative "liquid_renderer/table"

module Bridgetown
  class LiquidRenderer
    extend Forwardable

    private def_delegator :@site, :in_source_dir, :source_dir

    def initialize(site)
      @site = site

      # Set up Liquid file system access to components for the Render tag
      Liquid::Template.file_system = LiquidRenderer::FileSystem.new(
        @site.config.components_load_paths, "%s.liquid"
      )
      Liquid::Template.file_system.site = site

      Liquid::Template.error_mode = @site.config["liquid"]["error_mode"].to_sym
      reset
    end

    def reset
      @stats = {}
      @cache = {}
      Bridgetown::Converters::LiquidTemplates.cached_partials = {}
    end

    def file(filename)
      filename.match(filename_regex)
      filename = Regexp.last_match(2)
      LiquidRenderer::File.new(self, filename).tap do
        @stats[filename] ||= new_profile_hash
      end
    end

    def increment_bytes(filename, bytes)
      @stats[filename][:bytes] += bytes
    end

    def increment_time(filename, time)
      @stats[filename][:time] += time
    end

    def increment_count(filename)
      @stats[filename][:count] += 1
    end

    def stats_table(num_of_rows = 50)
      LiquidRenderer::Table.new(@stats).to_s(num_of_rows)
    end

    def self.format_error(error, path)
      "#{error.message} in #{path}"
    end

    # A persistent cache to store and retrieve parsed templates based on the filename
    # via `LiquidRenderer::File#parse`
    #
    # It is emptied when `self.reset` is called.
    def cache
      @cache ||= {}
    end

    private

    def filename_regex
      @filename_regex ||= %r!\A(#{Regexp.escape(source_dir)}/|/*)(.*)!i
    end

    def new_profile_hash
      Hash.new { |hash, key| hash[key] = 0 }
    end
  end
end

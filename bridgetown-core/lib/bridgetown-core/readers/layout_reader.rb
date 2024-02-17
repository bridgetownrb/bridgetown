# frozen_string_literal: true

module Bridgetown
  class LayoutReader
    attr_reader :site

    def initialize(site)
      @site = site
      @layouts = HashWithDotAccess::Hash.new
    end

    def read
      layout_entries.each do |layout_file|
        @layouts[layout_name(layout_file)] =
          Layout.new(site, layout_directory, layout_file)
      end

      site.config.source_manifests.filter_map(&:layouts).each do |plugin_layouts|
        layout_entries(plugin_layouts).each do |layout_file|
          @layouts[layout_name(layout_file)] ||=
            Layout.new(site, plugin_layouts, layout_file, from_plugin: true)
        end
      end

      @layouts
    end

    def layout_directory
      @layout_directory ||= site.in_source_dir(site.config["layouts_dir"])
    end

    private

    def layout_entries(dir = layout_directory)
      entries_in dir
    end

    def entries_in(dir)
      entries = []
      within(dir) do
        entries = EntryFilter.new(site).filter(Dir["**/*.*"])
      end
      entries
    end

    def layout_name(file)
      Layout.label_for_file(file)
    end

    def within(directory, &)
      return unless File.exist?(directory)

      Dir.chdir(directory, &)
    end
  end
end

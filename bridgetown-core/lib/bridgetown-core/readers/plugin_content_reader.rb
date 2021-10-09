# frozen_string_literal: true

module Bridgetown
  class PluginContentReader
    attr_reader :site, :content_dir

    def initialize(site, plugin_content_dir)
      @site = site
      @content_dir = plugin_content_dir
      @content_files = Set.new
    end

    def read
      return unless content_dir

      Find.find(content_dir) do |path|
        next if File.directory?(path)

        if File.symlink?(path)
          Bridgetown.logger.warn "Plugin content reader:", "Ignored symlinked asset: #{path}"
        else
          read_content_file(path)
        end
      end
    end

    def read_content_file(path)
      dir = File.dirname(path.sub("#{content_dir}/", ""))
      name = File.basename(path)

      @content_files << if Utils.has_yaml_header?(path)
                          Bridgetown::GeneratedPage.new(
                            site, content_dir, dir, name, from_plugin: true
                          )
                        else
                          Bridgetown::StaticFile.new(site, content_dir, "/#{dir}", name)
                        end

      add_to(site.generated_pages, Bridgetown::GeneratedPage)
      add_to(site.static_files, Bridgetown::StaticFile)
    end

    def add_to(content_type, klass)
      existing_paths = content_type.map(&:relative_path).compact
      @content_files.select { |item| item.is_a?(klass) }.each do |item|
        content_type << item unless existing_paths.include?(item.relative_path)
      end
    end
  end
end

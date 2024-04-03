# frozen_string_literal: true

module Bridgetown
  class PluginContentReader
    attr_reader :site, :manifest, :content_dir

    # @param site [Bridgetown::Site]
    # @param manifest [Bridgetown::Plugin::SourceManifest]
    def initialize(site, manifest)
      @site = site
      @manifest = manifest
      @content_dir = manifest.content
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

      @content_files << if FrontMatter::Loaders.front_matter?(path)
                          site.collections.pages.read_resource(path, manifest:)
                        else
                          Bridgetown::StaticFile.new(site, content_dir, "/#{dir}", name)
                        end
      add_to(site.static_files, Bridgetown::StaticFile)
    end

    def add_to(content_type, klass)
      existing_paths = content_type.filter_map(&:relative_path)
      @content_files.select { |item| item.is_a?(klass) }.each do |item|
        content_type << item unless existing_paths.include?(item.relative_path)
      end
    end
  end
end

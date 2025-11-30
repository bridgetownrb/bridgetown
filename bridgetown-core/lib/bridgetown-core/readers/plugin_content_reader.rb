# frozen_string_literal: true

module Bridgetown
  class PluginContentReader
    attr_reader :site, :manifest, :content_dirs

    # @param site [Bridgetown::Site]
    # @param manifest [Bridgetown::Plugin::SourceManifest]
    def initialize(site, manifest)
      @site = site
      @manifest = manifest
      @content_dirs = if manifest.contents
                        manifest.contents
                      elsif manifest.content
                        { pages: manifest.content }
                      end
      @content_files = Set.new
    end

    def read
      return if content_dirs.empty?

      content_dirs.each do |collection_name, root|
        read_content_root collection_name, root
      end
    end

    def read_content_root(collection_name, content_dir)
      collection = site.collections[collection_name]
      unless collection
        Bridgetown.logger.warn(
          "Reading",
          "Plugin requested missing collection #{collection_name}, cannot continue"
        )
        return
      end

      Find.find(content_dir) do |path|
        next if File.directory?(path)

        if File.symlink?(path)
          Bridgetown.logger.warn "Plugin content reader:", "Ignored symlinked asset: #{path}"
        else
          read_content_file(content_dir, path, collection)
        end
      end
    end

    def read_content_file(content_dir, path, collection)
      dir = File.dirname(path.sub("#{content_dir}/", ""))
      name = File.basename(path)

      @content_files << if FrontMatter::Loaders.front_matter?(path)
                          collection.read_resource(path, manifest:)
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

# frozen_string_literal: true

module Bridgetown
  class LiquidRenderer
    class FileSystem < Liquid::LocalFileSystem
      attr_accessor :site

      def read_template_file(template_path)
        load_paths = root
        found_paths = []

        load_paths.each do |load_path|
          # Use Liquid's gut checks to verify template pathname
          self.root = load_path
          full_template_path = full_path(template_path)

          # Look for .liquid as well as .html extensions
          path_variants = [
            Pathname.new(full_template_path),
            Pathname.new(full_template_path).sub_ext(".html"),
          ]

          found_paths << path_variants.find(&:exist?)
        end

        # Restore pristine state
        self.root = load_paths

        found_paths.compact!

        raise Liquid::FileSystemError, "No such template '#{template_path}'" if found_paths.empty?

        # Last path in the list wins
        ::File.read(found_paths.last, **site.file_read_opts)
      end
    end
  end
end

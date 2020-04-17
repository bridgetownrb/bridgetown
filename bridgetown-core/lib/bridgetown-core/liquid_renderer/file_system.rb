# frozen_string_literal: true

module Bridgetown
  class LiquidRenderer
    class FileSystem < Liquid::LocalFileSystem
      def read_template_file(template_path)
        full_path = full_path(template_path)

        path_variants = [
          Pathname.new(full_path),
          Pathname.new(full_path).sub_ext(".html"),
        ]

        full_path = path_variants.find(&:exist?)
        raise Liquid::FileSystemError, "No such template '#{template_path}'" unless full_path

        ::File.read(full_path)
      end
    end
  end
end

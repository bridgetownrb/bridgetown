# frozen_string_literal: true

module Bridgetown
  module FrontMatter
    module Loaders
      # Reads YAML-formatted front matter delineated by triple hyphens
      #
      # As an example, this resource loads to the hash `{"published": false,
      # "title": "My post"}`.
      #
      # ~~~
      # ---
      # published: false
      # title: My post
      # ---
      # ~~~
      class YAML < Base
        HEADER = %r!\A---\s*\n!.freeze
        BLOCK = %r!\A(---\s*\n.*?\n?)^((---|\.\.\.)\s*$\n?)!m.freeze

        # @see {Base#read}
        def read(file_contents, **)
          yaml_content = file_contents.match(BLOCK) or return

          Result.new(
            content: yaml_content.post_match,
            front_matter: YAMLParser.load(yaml_content[1]),
            line_count: yaml_content[1].lines.size - 1
          )
        end
      end
    end
  end
end

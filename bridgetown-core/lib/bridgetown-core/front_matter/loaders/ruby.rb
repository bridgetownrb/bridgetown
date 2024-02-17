# frozen_string_literal: true

module Bridgetown
  module FrontMatter
    module Loaders
      # Reads Ruby front matter delineated by fenced code blocks or ERB/Serbea indicators.
      #
      # For example, all of these resources load the hash `{published: false,
      # title: "My post"}` as their front matter.
      #
      # ~~~
      # ```ruby
      # {
      #   published: false,
      #   title: My post
      # }
      # ```
      # ~~~
      #
      # ~~~~
      # ~~~ruby
      # {
      #   published: false,
      #   title: My post
      # }
      # ~~~
      # ~~~~
      #
      # ~~~
      # ###ruby
      # {
      #   published: false,
      #   title: My post
      # }
      # ###
      # ~~~
      #
      # ~~~
      # ---ruby
      # {
      #   published: false,
      #   title: My post
      # }
      # ---
      # ~~~
      #
      # ~~~~
      # ~~~<%
      # {
      #   published: false,
      #   title: My post
      # }
      # %>~~~
      # ~~~~
      #
      # ~~~~
      # ~~~{%
      # {
      #   published: false,
      #   title: My post
      # }
      # %}~~~
      # ~~~~
      class Ruby < Base
        HEADER = %r!\A[~`#-]{3,}(?:ruby|<%|{%)\s*\n!
        BLOCK = %r!#{HEADER.source}(.*?\n?)^((?:%>|%})?[~`#-]{3,}\s*$\n?)!m

        # Determines whether a given file has Ruby front matter
        #
        # @param file [Pathname, String] the path to the file
        # @return [Boolean] true if the file has Ruby front matter, false otherwise
        def self.header?(file)
          File.open(file, "rb", &:gets)&.match?(HEADER) || false
        end

        # @see {Base#read}
        def read(file_contents, file_path:)
          if (ruby_content = file_contents.match(BLOCK)) && should_execute_inline_ruby?
            Result.new(
              content: ruby_content.post_match,
              front_matter: process_ruby_data(ruby_content[1], file_path, 2),
              line_count: ruby_content[1].lines.size
            )
          elsif self.class.header?(file_path)
            Result.new(
              front_matter: process_ruby_data(
                File.read(file_path).lines[1..].join("\n"),
                file_path,
                2
              ),
              line_count: 0
            )
          end
        end

        private

        def process_ruby_data(rubycode, file_path, starting_line)
          Bridgetown::Utils::RubyExec.process_ruby_data(
            @origin_or_layout,
            rubycode,
            file_path,
            starting_line
          )
        end

        def should_execute_inline_ruby?
          Bridgetown::Current.site.config.should_execute_inline_ruby?
        end
      end
    end
  end
end

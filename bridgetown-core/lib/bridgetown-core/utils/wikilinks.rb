# frozen_string_literal: true

module Bridgetown
  module Utils
    class Wikilinks
      # @param config [Bridgetown::Configuration::ConfigurationDSL]
      def self.setup_parsing_hook(config)
        markdown_exts = config.markdown_ext.split(",").map { ".#{_1}" }

        config.hook :resources, :pre_render, priority: :low do |resource|
          next unless markdown_exts.include?(resource.relative_path.extname)
          next if resource.data.bypass_wikilinks

          Wikilinks.new(resource:).convert
        end
      end

      # @param resource [Bridgetown::Resource::Base]
      def initialize(resource:)
        @resource = resource
        @site = resource.site
      end

      # Sets the resource's new content to the parsed string where `[[Wiki-style Links]]` are
      # turned into `[Wiki-style Links](...)`
      def convert
        @resource.content = parse_content(@resource.content)
      end

      # Parse all `[[wiki links]]` unless they're escaped, e.g. `\[[don't parse me bro]]`.
      # You can use a pipe character to control the displayed text of the link:
      # `[[Actual page title|Link text here]]`, and you can also add an anchor for the link:
      # `[[Page Title#page_section_anchor]]`
      # @param input [String]
      # @return String
      def parse_content(input)
        input.gsub %r!(\\?)\[\[(.+?)\]\]! do
          next "[[#{Regexp.last_match[2]}]]" if Regexp.last_match[1] == "\\"

          search_title, printed_title =
            Regexp.last_match[2].split("|").map(&:strip)
          search_title, anchor = search_title.split("#")
          anchor = "##{anchor}" if anchor
          title = printed_title || search_title
          found = @site.resources.find { _1.data.title == search_title }
          if found
            "[#{title}](#{found.relative_url}#{anchor}){:.wikilink}"
          else
            missing_title_strategy(title)
          end
        end
      end

      def missing_title_strategy(title)
        # TODO: this should be configurable
        "<u>#{title} (missing)</u>"
      end
    end
  end
end

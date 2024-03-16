# frozen_string_literal: true

module Bridgetown
  module FrontMatterImporter
    # Requires klass#content and klass#front_matter_line_count accessors
    def self.included(klass)
      klass.include Bridgetown::Utils::RubyFrontMatterDSL
    end

    YAML_HEADER = %r!\A---\s*\n!.freeze
    YAML_BLOCK = %r!\A(---\s*\n.*?\n?)^((---|\.\.\.)\s*$\n?)!m.freeze
    RUBY_HEADER = %r!\A[~`#-]{3,}(?:ruby|<%|{%)\s*\n!.freeze
    RUBY_BLOCK =
      %r!#{RUBY_HEADER.source}(.*?\n?)^((?:%>|%})?[~`#-]{3,}\s*$\n?)!m.freeze

    def read_front_matter(file_path) # rubocop:todo Metrics/AbcSize, Metrics/CyclomaticComplexity, Metrics/PerceivedComplexity, Metrics/MethodLength
      file_contents = File.read(
        file_path, **Bridgetown::Utils.merged_file_read_opts(Bridgetown::Current.site, {})
      )
      yaml_content = file_contents.match(YAML_BLOCK)
      if !yaml_content && Bridgetown::Current.site.config.should_execute_inline_ruby?
        ruby_content = file_contents.match(RUBY_BLOCK)
      end

      if yaml_content
        self.content = yaml_content.post_match
        self.front_matter_line_count = yaml_content[1].lines.size - 1
        YAMLParser.load(yaml_content[1])
      elsif ruby_content
        # rbfm header + content underneath
        self.content = ruby_content.post_match
        self.front_matter_line_count = ruby_content[1].lines.size
        process_ruby_data(ruby_content[1], file_path, 2)
      elsif Bridgetown::Utils.has_rbfm_header?(file_path)
        process_ruby_data(File.read(file_path).lines[1..].join("\n"), file_path, 2)
      elsif is_a?(Layout)
        self.content = file_contents
        {}
      else
        yaml_data = YAMLParser.load_file(file_path)
        yaml_data.is_a?(Array) ? { rows: yaml_data } : yaml_data
      end
    end

    def process_ruby_data(rubycode, file_path, starting_line)
      ruby_data = instance_eval(rubycode, file_path.to_s, starting_line)
      ruby_data.is_a?(Array) ? { rows: ruby_data } : ruby_data.to_h
    rescue StandardError => e
      raise "Ruby code isn't returning an array, or object which responds to `to_h' (#{e.message})"
    end
  end
end

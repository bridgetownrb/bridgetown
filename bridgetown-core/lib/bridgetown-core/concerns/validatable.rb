# frozen_string_literal: true

module Bridgetown
  # TODO: to be retired once the Resource engine is made official
  module Validatable
    # FIXME: there should be ONE TRUE METHOD to read the YAML frontmatter
    # in the entire project. Both this and the equivalent Document method
    # should be extracted and generalized.
    #
    # Read the YAML frontmatter.
    #
    # base - The String path to the dir containing the file.
    # name - The String filename of the file.
    # opts - optional parameter to File.read, default at site configs
    #
    # Returns nothing.
    # rubocop:disable Metrics/AbcSize
    def read_yaml(base, name, opts = {})
      filename = File.join(base, name)

      begin
        self.content = File.read(@path || site.in_source_dir(base, name),
                                 **Utils.merged_file_read_opts(site, opts))
        if content =~ Document::YAML_FRONT_MATTER_REGEXP
          self.content = $POSTMATCH
          self.data = SafeYAML.load(Regexp.last_match(1))&.with_dot_access
        end
      rescue Psych::SyntaxError => e
        Bridgetown.logger.warn "YAML Exception reading #{filename}: #{e.message}"
        raise e if site.config["strict_front_matter"]
      rescue StandardError => e
        Bridgetown.logger.warn "Error reading file #{filename}: #{e.message}"
        raise e if site.config["strict_front_matter"]
      end

      self.data ||= HashWithDotAccess::Hash.new

      validate_data! filename
      validate_permalink! filename

      self.data
    end
    # rubocop:enable Metrics/AbcSize

    # FIXME: why doesn't Document validate data too?
    def validate_data!(filename)
      unless self.data.is_a?(Hash)
        raise Errors::InvalidYAMLFrontMatterError,
              "Invalid YAML front matter in #{filename}"
      end
    end

    # FIXME: Layouts don't have permalinks...d'oh
    def validate_permalink!(filename)
      if self.data["permalink"]&.to_s&.empty?
        raise Errors::InvalidPermalinkError, "Invalid permalink in #{filename}"
      end
    end
  end
end

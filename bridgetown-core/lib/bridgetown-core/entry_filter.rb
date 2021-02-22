# frozen_string_literal: true

module Bridgetown
  class EntryFilter
    attr_reader :site
    SPECIAL_LEADING_CHAR_REGEX = %r!\A#{Regexp.union([".", "_", "#", "~"])}!o.freeze
    SPECIAL_LEADING_CHAR_NO_UNDERSCORES_REGEX = %r!\A#{Regexp.union([".", "#", "~"])}!o.freeze

    def initialize(site, base_directory: nil, include_underscores: false)
      @site = site
      @base_directory = derive_base_directory(
        @site, base_directory.to_s.dup
      )
      @include_underscores = include_underscores
    end

    def base_directory
      @base_directory.to_s
    end

    def derive_base_directory(site, base_dir)
      base_dir[site.source] = "" if base_dir.start_with?(site.source)
      base_dir
    end

    def relative_to_source(entry)
      File.join(
        base_directory, entry
      )
    end

    def filter(entries)
      entries.reject do |e|
        # Reject this entry if it is just a "dot" representation.
        #   e.g.: '.', '..', '_movies/.', 'music/..', etc
        next true if e.end_with?(".")
        # Reject this entry if it is a symlink.
        next true if symlink?(e)
        # Do not reject this entry if it is included.
        next false if included?(e)

        # Reject this entry if it is special, a backup file, or excluded.
        special?(e) || backup?(e) || excluded?(e)
      end
    end

    def included?(entry)
      glob_include?(site.include, entry) ||
        glob_include?(site.include, File.basename(entry))
    end

    def special?(entry)
      use_regex = if @include_underscores
                    SPECIAL_LEADING_CHAR_NO_UNDERSCORES_REGEX
                  else
                    SPECIAL_LEADING_CHAR_REGEX
                  end

      use_regex.match?(entry) || use_regex.match?(File.basename(entry))
    end

    def backup?(entry)
      entry.end_with?("~")
    end

    def excluded?(entry)
      glob_include?(site.exclude - site.include, relative_to_source(entry)).tap do |excluded|
        if excluded
          Bridgetown.logger.debug(
            "EntryFilter:",
            "excluded #{relative_to_source(entry)}"
          )
        end
      end
    end

    # --
    # TODO: this is for old Safe mode and can be removed.
    # --
    def symlink?(_entry)
      false
    end

    # --
    # NOTE: Pathutil#in_path? gets the realpath.
    # @param [<Anything>] entry the entry you want to validate.
    # Check if a path is outside of our given root.
    # --
    def symlink_outside_site_source?(entry)
      !Pathutil.new(entry).in_path?(
        site.in_source_dir
      )
    end

    # Check if an entry matches a specific pattern.
    # Returns true if path matches against any glob pattern, else false.
    def glob_include?(enumerator, entry)
      entry_with_source = PathManager.join(site.source, entry)

      enumerator.any? do |pattern|
        case pattern
        when String
          pattern_with_source = PathManager.join(site.source, pattern)

          File.fnmatch?(pattern_with_source, entry_with_source) ||
            entry_with_source.start_with?(pattern_with_source)
        when Regexp
          pattern.match?(entry_with_source)
        else
          false
        end
      end
    end
  end
end

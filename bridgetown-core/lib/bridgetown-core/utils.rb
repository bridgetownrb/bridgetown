# frozen_string_literal: true

module Bridgetown
  module Utils # rubocop:todo Metrics/ModuleLength
    extend self
    autoload :Ansi, "bridgetown-core/utils/ansi"
    autoload :Aux, "bridgetown-core/utils/aux"
    autoload :LoadersManager, "bridgetown-core/utils/loaders_manager"
    autoload :RequireGems, "bridgetown-core/utils/require_gems"
    autoload :RubyExec, "bridgetown-core/utils/ruby_exec"
    autoload :RubyFrontMatter, "bridgetown-core/utils/ruby_front_matter"
    autoload :RubyFrontMatterDSL, "bridgetown-core/utils/ruby_front_matter"

    # Constants for use in #slugify
    SLUGIFY_MODES = %w(raw default pretty simple ascii latin).freeze
    SLUGIFY_RAW_REGEXP = Regexp.new("\\s+").freeze
    SLUGIFY_DEFAULT_REGEXP = Regexp.new("[^\\p{M}\\p{L}\\p{Nd}]+").freeze
    SLUGIFY_PRETTY_REGEXP = Regexp.new("[^\\p{M}\\p{L}\\p{Nd}._~!$&'()+,;=@]+").freeze
    SLUGIFY_ASCII_REGEXP = Regexp.new("[^[A-Za-z0-9]]+").freeze

    # Takes a slug and turns it into a simple title.
    def titleize_slug(slug)
      slug.gsub(%r![_ ]!, "-").split("-").map!(&:capitalize).join(" ")
    end

    # XML escape a string for use. Replaces any special characters with
    # appropriate HTML entity replacements.
    #
    # Examples
    #
    #   xml_escape('foo "bar" <baz>')
    #   # => "foo &quot;bar&quot; &lt;baz&gt;"
    #
    # @param input [String] The String to escape.
    # @return [String] the escaped String.
    def xml_escape(input)
      input.to_s.encode(xml: :attr).gsub(%r!\A"|"\Z!, "")
    end

    # Non-destructive version of deep_merge_hashes! See that method.
    #
    # Returns the merged hashes.
    def deep_merge_hashes(master_hash, other_hash)
      deep_merge_hashes!(master_hash.dup, other_hash)
    end

    # Merges a master hash with another hash, recursively.
    #
    # master_hash - the "parent" hash whose values will be overridden
    # other_hash  - the other hash whose values will be persisted after the merge
    #
    # This code was lovingly stolen from some random gem:
    # http://gemjack.com/gems/tartan-0.1.1/classes/Hash.html
    #
    # Thanks to whoever made it.
    def deep_merge_hashes!(target, overwrite)
      merge_values(target, overwrite)
      merge_default_proc(target, overwrite)
      duplicate_frozen_values(target)

      target
    end

    def mergable?(value)
      value.is_a?(Hash) || value.is_a?(Drops::Drop)
    end

    def duplicable?(obj)
      case obj
      when nil, false, true, Symbol, Numeric
        false
      else
        true
      end
    end

    # Read array from the supplied hash, merging the singular key with the
    # plural key as needing, and handling any nil or duplicate entries.
    #
    # @param hsh [Hash] the hash to read from
    # @param singular_key [Symbol] the singular key
    # @param plural_key [Symbol] the plural key
    # @return [Array]
    def pluralized_array_from_hash(hsh, singular_key, plural_key)
      array = [
        hsh[singular_key],
        value_from_plural_key(hsh, plural_key),
      ]

      array.flatten!
      array.compact!
      array.uniq!
      array
    end

    def value_from_plural_key(hsh, key)
      val = hsh[key]
      case val
      when String
        val.split
      when Array
        val.compact
      end
    end

    # Parse a date/time and throw an error if invalid
    #
    # input - the date/time to parse
    # msg - (optional) the error message to show the user
    #
    # Returns the parsed date if successful, throws a FatalException
    # if not
    def parse_date(input, msg = "Input could not be parsed.")
      Time.parse(input).localtime
    rescue ArgumentError
      raise Errors::InvalidDateError, "Invalid date '#{input}': #{msg}"
    end

    # Determines whether a given file has
    #
    # @return [Boolean] if the YAML front matter is present.
    # rubocop: disable Naming/PredicateName
    def has_yaml_header?(file)
      File.open(file, "rb", &:readline).match? Bridgetown::FrontMatterImporter::YAML_HEADER
    rescue EOFError
      false
    end

    def has_rbfm_header?(file)
      File.open(file, "rb", &:readline).match? Bridgetown::FrontMatterImporter::RUBY_HEADER
    rescue EOFError
      false
    end

    # Determine whether the given content string contains Liquid Tags or Vaiables
    #
    # @return [Boolean] if the string contains sequences of `{%` or `{{`
    def has_liquid_construct?(content)
      return false if content.nil? || content.empty?

      content.include?("{%") || content.include?("{{")
    end
    # rubocop: enable Naming/PredicateName

    # Slugify a filename or title.
    #
    # string - the filename or title to slugify
    # mode - how string is slugified
    # cased - whether to replace all uppercase letters with their
    # lowercase counterparts
    #
    # When mode is "none", return the given string.
    #
    # When mode is "raw", return the given string,
    # with every sequence of spaces characters replaced with a hyphen.
    #
    # When mode is "default", "simple", or nil, non-alphabetic characters are
    # replaced with a hyphen too.
    #
    # When mode is "pretty", some non-alphabetic characters (._~!$&'()+,;=@)
    # are not replaced with hyphen.
    #
    # When mode is "ascii", some everything else except ASCII characters
    # a-z (lowercase), A-Z (uppercase) and 0-9 (numbers) are not replaced with hyphen.
    #
    # When mode is "latin", the input string is first preprocessed so that
    # any letters with accents are replaced with the plain letter. Afterwards,
    # it follows the "default" mode of operation.
    #
    # If cased is true, all uppercase letters in the result string are
    # replaced with their lowercase counterparts.
    #
    # Examples:
    #   slugify("The _config.yml file")
    #   # => "the-config-yml-file"
    #
    #   slugify("The _config.yml file", "pretty")
    #   # => "the-_config.yml-file"
    #
    #   slugify("The _config.yml file", "pretty", true)
    #   # => "The-_config.yml file"
    #
    #   slugify("The _config.yml file", "ascii")
    #   # => "the-config-yml-file"
    #
    #   slugify("The _config.yml file", "latin")
    #   # => "the-config-yml-file"
    #
    # Returns the slugified string.
    def slugify(string, mode: nil, cased: false)
      mode ||= "default"
      return nil if string.nil?

      unless SLUGIFY_MODES.include?(mode)
        return cased ? string : string.downcase
      end

      # Drop accent marks from latin characters. Everything else turns to ?
      if mode == "latin"
        I18n.config.available_locales = :en if I18n.config.available_locales.empty?
        string = I18n.transliterate(string)
      end

      slug = replace_character_sequence_with_hyphen(string, mode: mode)

      # Remove leading/trailing hyphen
      slug.gsub!(%r!^-|-$!i, "")

      slug.downcase! unless cased

      slug
    end

    # Add an appropriate suffix to template so that it matches the specified
    # permalink style.
    #
    # template - permalink template without trailing slash or file extension
    # permalink_style - permalink style, either built-in or custom
    #
    # The returned permalink template will use the same ending style as
    # specified in permalink_style.  For example, if permalink_style contains a
    # trailing slash (or is :pretty, which indirectly has a trailing slash),
    # then so will the returned template.  If permalink_style has a trailing
    # ":output_ext" (or is :none, :date, or :ordinal) then so will the returned
    # template.  Otherwise, template will be returned without modification.
    #
    # Examples:
    #   add_permalink_suffix("/:basename", :pretty)
    #   # => "/:basename/"
    #
    #   add_permalink_suffix("/:basename", :date)
    #   # => "/:basename:output_ext"
    #
    #   add_permalink_suffix("/:basename", "/:year/:month/:title/")
    #   # => "/:basename/"
    #
    #   add_permalink_suffix("/:basename", "/:year/:month/:title")
    #   # => "/:basename"
    #
    # Returns the updated permalink template
    def add_permalink_suffix(template, permalink_style)
      template = template.dup

      case permalink_style
      when :pretty, :simple
        template << "/"
      when :date, :ordinal, :none
        template << ":output_ext"
      else
        template << "/" if permalink_style.to_s.end_with?("/")
        template << ":output_ext" if permalink_style.to_s.end_with?(":output_ext")
      end

      template
    end

    # Work the same way as Dir.glob but seperating the input into two parts
    # ('dir' + '/' + 'pattern') to make sure the first part('dir') does not act
    # as a pattern.
    #
    # For example, Dir.glob("path[/*") always returns an empty array,
    # because the method fails to find the closing pattern to '[' which is ']'
    #
    # Examples:
    #   safe_glob("path[", "*")
    #   # => ["path[/file1", "path[/file2"]
    #
    #   safe_glob("path", "*", File::FNM_DOTMATCH)
    #   # => ["path/.", "path/..", "path/file1"]
    #
    #   safe_glob("path", ["**", "*"])
    #   # => ["path[/file1", "path[/folder/file2"]
    #
    # dir      - the dir where glob will be executed under
    #           (the dir will be included to each result)
    # patterns - the patterns (or the pattern) which will be applied under the dir
    # flags    - the flags which will be applied to the pattern
    #
    # Returns matched pathes
    def safe_glob(dir, patterns, flags = 0)
      return [] unless Dir.exist?(dir)

      pattern = File.join(Array(patterns))
      return [dir] if pattern.empty?

      Dir.chdir(dir) do
        Dir.glob(pattern, flags).map { |f| File.join(dir, f) }
      end
    end

    # Returns merged option hash for File.read of self.site (if exists)
    # and a given param
    def merged_file_read_opts(site, opts)
      merged = (site ? site.file_read_opts : {}).merge(opts)
      if merged[:encoding] && !merged[:encoding].start_with?("bom|")
        merged[:encoding] = "bom|#{merged[:encoding]}"
      end
      if merged["encoding"] && !merged["encoding"].start_with?("bom|")
        merged["encoding"] = "bom|#{merged["encoding"]}"
      end
      merged
    end

    # Returns a string that's been reindented so that Markdown's four+ spaces =
    # code doesn't get triggered for nested Liquid components
    # rubocop:disable Metrics/AbcSize, Metrics/MethodLength, Metrics/PerceivedComplexity
    def reindent_for_markdown(input)
      lines = input.lines
      return input if lines.first.nil?

      starting_indentation = lines.find { |line| line != "\n" }&.match(%r!^ +!)
      return input unless starting_indentation

      starting_indent_length = starting_indentation[0].length

      skip_pre_lines = false
      lines.map do |line|
        continue_processing = !skip_pre_lines

        skip_pre_lines = false if skip_pre_lines && line.include?("</pre>")
        if line.include?("<pre")
          skip_pre_lines = true
          continue_processing = false
        end

        if continue_processing
          line_indentation = line.match(%r!^ +!).yield_self do |indent|
            indent.nil? ? "" : indent[0]
          end
          new_indentation = line_indentation.rjust(starting_indent_length, " ")

          if %r!^ +!.match?(line)
            line
              .sub(%r!^ {1,#{starting_indent_length}}!, new_indentation)
              .sub(%r!^#{new_indentation}!, "")
          else
            line
          end
        else
          line
        end
      end.join
    end
    # rubocop:enable Metrics/AbcSize, Metrics/MethodLength, Metrics/PerceivedComplexity

    # Return an asset path based on the Webpack manifest file
    # @param site [Bridgetown::Site] The current site object
    # @param asset_type [String] js or css, or filename in manifest
    #
    # @return [String] Returns "MISSING_WEBPACK_MANIFEST" if the manifest
    # file isnt found
    # @return [nil] Returns nil if the asset isnt found
    # @return [String] Returns the path to the asset if no issues parsing
    #
    # @raise [WebpackAssetError] if unable to find css or js in the manifest
    # file
    def parse_webpack_manifest_file(site, asset_type)
      return log_webpack_asset_error("Webpack manifest") if site.frontend_manifest.nil?

      asset_path = if %w(js css).include?(asset_type)
                     site.frontend_manifest["main.#{asset_type}"]
                   else
                     site.frontend_manifest.find do |item, _|
                       item.sub(%r{^../(frontend/|src/)?}, "") == asset_type
                     end&.last
                   end

      return log_webpack_asset_error(asset_type) if asset_path.nil?

      static_frontend_path site, ["js", asset_path]
    end

    def static_frontend_path(site, additional_parts = [])
      path_parts = [
        site.base_path.gsub(%r(^/|/$), ""),
        "_bridgetown/static",
        *additional_parts,
      ]
      path_parts[0] = "/#{path_parts[0]}" unless path_parts[0].empty?
      Addressable::URI.parse(path_parts.join("/")).normalize.to_s
    end

    def log_webpack_asset_error(asset_type)
      Bridgetown.logger.warn(
        "Webpack:",
        "There was an error parsing your #{asset_type} file. \
        Please check your #{asset_type} file for any errors."
      )

      "MISSING_WEBPACK_MANIFEST_FILE"
    end

    def default_github_branch_name(repo_url)
      repo_match = Bridgetown::Commands::Actions::GITHUB_REPO_REGEX.match(repo_url)
      api_endpoint = "https://api.github.com/repos/#{repo_match[1]}"
      JSON.parse(Faraday.get(api_endpoint).body)["default_branch"] || "master"
    rescue StandardError => e
      Bridgetown.logger.warn("Unable to connect to GitHub API: #{e.message}")
      "master"
    end

    def live_reload_js(site) # rubocop:disable Metrics/MethodLength
      return "" unless Bridgetown.env.development? && !site.config.skip_live_reload

      code = <<~JAVASCRIPT
        let first_mod = 0
        let connection_errors = 0
        const checkForReload = () => {
          fetch("/_bridgetown/live_reload").then(response => {
            if (response.ok) {
              response.json().then(data => {
                const last_mod = data.last_mod
                if (first_mod === 0) {
                  first_mod = last_mod
                } else if (last_mod > first_mod) {
                  location.reload()
                }
                setTimeout(() => checkForReload(), 700)
              })
            } else {
              if (connection_errors < 20) setTimeout(() => checkForReload(), 6000)
              connection_errors++
            }
          }).catch((err) => {
            if (connection_errors < 20) setTimeout(() => checkForReload(), 6000)
            connection_errors++
          })
        }
        checkForReload()
      JAVASCRIPT

      %(<script type="module">#{code}</script>).html_safe
    end

    private

    def merge_values(target, overwrite)
      target.merge!(overwrite) do |_key, old_val, new_val|
        if new_val.nil?
          old_val
        elsif mergable?(old_val) && mergable?(new_val)
          deep_merge_hashes(old_val, new_val)
        else
          new_val
        end
      end
    end

    def merge_default_proc(target, overwrite)
      return unless target.is_a?(Hash) && overwrite.is_a?(Hash) && target.default_proc.nil?

      target.default_proc = overwrite.default_proc
    end

    def duplicate_frozen_values(target)
      target.each do |key, val|
        target[key] = val.dup if val.frozen? && duplicable?(val)
      end
    end

    # Replace each character sequence with a hyphen.
    #
    # See Utils#slugify for a description of the character sequence specified
    # by each mode.
    def replace_character_sequence_with_hyphen(string, mode: "default")
      replaceable_char =
        case mode
        when "raw"
          SLUGIFY_RAW_REGEXP
        when "pretty"
          # "._~!$&'()+,;=@" is human readable (not URI-escaped) in URL
          # and is allowed in both extN and NTFS.
          SLUGIFY_PRETTY_REGEXP
        when "ascii"
          # For web servers not being able to handle Unicode, the safe
          # method is to ditch anything else but latin letters and numeric
          # digits.
          SLUGIFY_ASCII_REGEXP
        else
          SLUGIFY_DEFAULT_REGEXP
        end

      # Strip according to the mode
      string.to_s.gsub(replaceable_char, "-")
    end
  end
end

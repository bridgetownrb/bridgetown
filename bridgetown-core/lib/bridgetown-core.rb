# frozen_string_literal: true

$LOAD_PATH.unshift __dir__ # For use/testing when no gem is installed

# Require all of the Ruby files in the given directory.
#
# path - The String relative path from here to the directory.
#
# Returns nothing.
def require_all(path)
  glob = File.join(__dir__, path, "*.rb")
  Dir[glob].sort.each do |f|
    require f
  end
end

# rubygems
require "rubygems"

# stdlib
require "forwardable"
require "fileutils"
require "time"
require "English"
require "pathname"
require "logger"
require "set"
require "csv"
require "json"

# 3rd party
require "pathutil"
require "addressable/uri"
require "safe_yaml/load"
require "liquid"
require "kramdown"
require "colorator"
require "i18n"

SafeYAML::OPTIONS[:suppress_warnings] = true

# Create our little String subclass for Ruby Front Matter
class Rb < String; end
SafeYAML::OPTIONS[:whitelisted_tags] = ["!ruby/string:Rb"]

module Bridgetown
  # internal requires
  autoload :Cleaner,             "bridgetown-core/cleaner"
  autoload :Collection,          "bridgetown-core/collection"
  autoload :Configuration,       "bridgetown-core/configuration"
  autoload :Convertible,         "bridgetown-core/convertible"
  autoload :Deprecator,          "bridgetown-core/deprecator"
  autoload :Document,            "bridgetown-core/document"
  autoload :EntryFilter,         "bridgetown-core/entry_filter"
  autoload :Errors,              "bridgetown-core/errors"
  autoload :Excerpt,             "bridgetown-core/excerpt"
  autoload :External,            "bridgetown-core/external"
  autoload :FrontmatterDefaults, "bridgetown-core/frontmatter_defaults"
  autoload :Hooks,               "bridgetown-core/hooks"
  autoload :Layout,              "bridgetown-core/layout"
  autoload :Cache,               "bridgetown-core/cache"
  autoload :CollectionReader,    "bridgetown-core/readers/collection_reader"
  autoload :DataReader,          "bridgetown-core/readers/data_reader"
  autoload :LayoutReader,        "bridgetown-core/readers/layout_reader"
  autoload :PostReader,          "bridgetown-core/readers/post_reader"
  autoload :PageReader,          "bridgetown-core/readers/page_reader"
  autoload :StaticFileReader,    "bridgetown-core/readers/static_file_reader"
  autoload :LogAdapter,          "bridgetown-core/log_adapter"
  autoload :Page,                "bridgetown-core/page"
  autoload :PageWithoutAFile,    "bridgetown-core/page_without_a_file"
  autoload :PathManager,         "bridgetown-core/path_manager"
  autoload :PluginManager,       "bridgetown-core/plugin_manager"
  autoload :Publisher,           "bridgetown-core/publisher"
  autoload :Reader,              "bridgetown-core/reader"
  autoload :Regenerator,         "bridgetown-core/regenerator"
  autoload :RelatedPosts,        "bridgetown-core/related_posts"
  autoload :Renderer,            "bridgetown-core/renderer"
  autoload :LiquidRenderer,      "bridgetown-core/liquid_renderer"
  autoload :LogWriter,           "bridgetown-core/log_writer"
  autoload :Site,                "bridgetown-core/site"
  autoload :StaticFile,          "bridgetown-core/static_file"
  autoload :URL,                 "bridgetown-core/url"
  autoload :Utils,               "bridgetown-core/utils"
  autoload :VERSION,             "bridgetown-core/version"
  autoload :Watcher,             "bridgetown-core/watcher"

  # extensions
  require "bridgetown-core/plugin"
  require "bridgetown-core/converter"
  require "bridgetown-core/generator"
  require "bridgetown-core/command"
  require "bridgetown-core/liquid_extensions"
  require "bridgetown-core/filters"

  require "bridgetown-core/drops/drop"
  require "bridgetown-core/drops/document_drop"
  require_all "bridgetown-core/commands"
  require_all "bridgetown-core/converters"
  require_all "bridgetown-core/converters/markdown"
  require_all "bridgetown-core/drops"
  require_all "bridgetown-core/generators"
  require_all "bridgetown-core/tags"

  class << self
    # Public: Tells you which Bridgetown environment you are building in so
    # you can skip tasks if you need to.

    def env
      ENV["BRIDGETOWN_ENV"] || "development"
    end

    # Public: Generate a Bridgetown configuration Hash by merging the default
    # options with anything in bridgetown.config.yml, and adding the given
    # options on top.
    #
    # override - A Hash of config directives that override any options in both
    #            the defaults and the config file.
    #            See Bridgetown::Configuration::DEFAULTS for a
    #            list of option names and their defaults.
    #
    # Returns the final configuration Hash.
    def configuration(override = {})
      config = Configuration.new
      override = Configuration[override].stringify_keys
      unless override.delete("skip_config_files")
        config = config.read_config_files(config.config_files(override))
      end

      # Merge DEFAULTS < bridgetown.config.yml < override
      Configuration.from(Utils.deep_merge_hashes(config, override)).tap do |obj|
        set_timezone(obj["timezone"]) if obj["timezone"]
      end
    end

    # Public: Set the TZ environment variable to use the timezone specified
    #
    # timezone - the IANA Time Zone
    #
    # Returns nothing
    # rubocop:disable Naming/AccessorMethodName
    def set_timezone(timezone)
      ENV["TZ"] = if Utils::Platforms.really_windows?
                    Utils::WinTZ.calculate(timezone)
                  else
                    timezone
                  end
    end
    # rubocop:enable Naming/AccessorMethodName

    # Public: Fetch the logger instance for this Bridgetown process.
    #
    # Returns the LogAdapter instance.
    def logger
      @logger ||= LogAdapter.new(LogWriter.new, (ENV["BRIDGETOWN_LOG_LEVEL"] || :info).to_sym)
    end

    # Public: Set the log writer.
    #         New log writer must respond to the same methods
    #         as Ruby's interal Logger.
    #
    # writer - the new Logger-compatible log transport
    #
    # Returns the new logger.
    def logger=(writer)
      @logger = LogAdapter.new(writer, (ENV["BRIDGETOWN_LOG_LEVEL"] || :info).to_sym)
    end

    # Public: An array of sites
    #
    # Returns the Bridgetown sites created.
    def sites
      @sites ||= []
    end

    # Public: Ensures the questionable path is prefixed with the base directory
    #         and prepends the questionable path with the base directory if false.
    #
    # base_directory - the directory with which to prefix the questionable path
    # questionable_path - the path we're unsure about, and want prefixed
    #
    # Returns the sanitized path.
    def sanitized_path(base_directory, questionable_path)
      return base_directory if base_directory.eql?(questionable_path)

      clean_path = questionable_path.dup
      clean_path.insert(0, "/") if clean_path.start_with?("~")
      clean_path = File.expand_path(clean_path, "/")

      return clean_path if clean_path.eql?(base_directory)

      # remove any remaining extra leading slashes not stripped away by calling
      # `File.expand_path` above.
      clean_path.squeeze!("/")

      if clean_path.start_with?(base_directory.sub(%r!\z!, "/"))
        clean_path
      else
        clean_path.sub!(%r!\A\w:/!, "/")
        File.join(base_directory, clean_path)
      end
    end

    # Conditional optimizations
    Bridgetown::External.require_if_present("liquid/c")
  end
end

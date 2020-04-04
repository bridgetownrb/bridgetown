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

module Bridgetown
  # internal requires
  autoload :Cleaner,             "bridgetown/cleaner"
  autoload :Collection,          "bridgetown/collection"
  autoload :Configuration,       "bridgetown/configuration"
  autoload :Convertible,         "bridgetown/convertible"
  autoload :Deprecator,          "bridgetown/deprecator"
  autoload :Document,            "bridgetown/document"
  autoload :EntryFilter,         "bridgetown/entry_filter"
  autoload :Errors,              "bridgetown/errors"
  autoload :Excerpt,             "bridgetown/excerpt"
  autoload :External,            "bridgetown/external"
  autoload :FrontmatterDefaults, "bridgetown/frontmatter_defaults"
  autoload :Hooks,               "bridgetown/hooks"
  autoload :Layout,              "bridgetown/layout"
  autoload :Cache,               "bridgetown/cache"
  autoload :CollectionReader,    "bridgetown/readers/collection_reader"
  autoload :DataReader,          "bridgetown/readers/data_reader"
  autoload :LayoutReader,        "bridgetown/readers/layout_reader"
  autoload :PostReader,          "bridgetown/readers/post_reader"
  autoload :PageReader,          "bridgetown/readers/page_reader"
  autoload :StaticFileReader,    "bridgetown/readers/static_file_reader"
  autoload :LogAdapter,          "bridgetown/log_adapter"
  autoload :Page,                "bridgetown/page"
  autoload :PageWithoutAFile,    "bridgetown/page_without_a_file"
  autoload :PathManager,         "bridgetown/path_manager"
  autoload :PluginManager,       "bridgetown/plugin_manager"
  autoload :Publisher,           "bridgetown/publisher"
  autoload :Reader,              "bridgetown/reader"
  autoload :Regenerator,         "bridgetown/regenerator"
  autoload :RelatedPosts,        "bridgetown/related_posts"
  autoload :Renderer,            "bridgetown/renderer"
  autoload :LiquidRenderer,      "bridgetown/liquid_renderer"
  autoload :LogWriter,           "bridgetown/log_writer"
  autoload :Site,                "bridgetown/site"
  autoload :StaticFile,          "bridgetown/static_file"
  autoload :URL,                 "bridgetown/url"
  autoload :Utils,               "bridgetown/utils"
  autoload :VERSION,             "bridgetown/version"
  autoload :Watcher,             "bridgetown/watcher"

  # extensions
  require "bridgetown/plugin"
  require "bridgetown/converter"
  require "bridgetown/generator"
  require "bridgetown/command"
  require "bridgetown/liquid_extensions"
  require "bridgetown/filters"

  class << self
    # Public: Tells you which Bridgetown environment you are building in so you can skip tasks
    # if you need to.  This is useful when doing expensive compression tasks on css and
    # images and allows you to skip that when working in development.

    def env
      ENV["BRIDGETOWN_ENV"] || "development"
    end

    # Public: Generate a Bridgetown configuration Hash by merging the default
    # options with anything in _config.yml, and adding the given options on top.
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

      # Merge DEFAULTS < _config.yml < override
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

require "bridgetown/drops/drop"
require "bridgetown/drops/document_drop"
require_all "bridgetown/commands"
require_all "bridgetown/converters"
require_all "bridgetown/converters/markdown"
require_all "bridgetown/drops"
require_all "bridgetown/generators"
require_all "bridgetown/tags"

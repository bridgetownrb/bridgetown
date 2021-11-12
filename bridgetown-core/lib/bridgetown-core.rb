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
require "find"
require "forwardable"
require "fileutils"
require "time"
require "English"
require "pathname"
require "logger"
require "set"
require "csv"
require "json"
require "yaml"

# 3rd party
require "active_support"
require "active_support/core_ext/hash/keys"
require "active_support/core_ext/module/delegation"
require "active_support/core_ext/object/blank"
require "active_support/core_ext/object/deep_dup"
require "active_support/core_ext/object/inclusion"
require "active_support/core_ext/string/inflections"
require "active_support/core_ext/string/inquiry"
require "active_support/core_ext/string/output_safety"
require "active_support/core_ext/string/starts_ends_with"
require "active_support/current_attributes"
require "active_support/descendants_tracker"
require "hash_with_dot_access"
require "addressable/uri"
require "liquid"
require "listen"
require "kramdown"
require "colorator"
require "i18n"
require "faraday"
require "thor"
require "zeitwerk"

module HashWithDotAccess
  class Hash # :nodoc:
    def to_liquid
      to_h.to_liquid
    end
  end
end

# Create our little String subclass for Ruby Front Matter
class Rb < String; end

module Bridgetown
  autoload :Cache,               "bridgetown-core/cache"
  autoload :Current,             "bridgetown-core/current"
  autoload :Cleaner,             "bridgetown-core/cleaner"
  autoload :Collection,          "bridgetown-core/collection"
  autoload :Component,           "bridgetown-core/component"
  autoload :Configuration,       "bridgetown-core/configuration"
  autoload :DefaultsReader,      "bridgetown-core/readers/defaults_reader"
  autoload :Deprecator,          "bridgetown-core/deprecator"
  autoload :EntryFilter,         "bridgetown-core/entry_filter"
  # TODO: we have too many errors! This is silly
  autoload :Errors,              "bridgetown-core/errors"
  autoload :FrontmatterDefaults, "bridgetown-core/frontmatter_defaults"
  autoload :FrontMatterImporter, "bridgetown-core/concerns/front_matter_importer"
  autoload :GeneratedPage,       "bridgetown-core/generated_page"
  autoload :Hooks,               "bridgetown-core/hooks"
  autoload :Layout,              "bridgetown-core/layout"
  autoload :LayoutPlaceable,     "bridgetown-core/concerns/layout_placeable"
  autoload :LayoutReader,        "bridgetown-core/readers/layout_reader"
  autoload :LiquidRenderable,    "bridgetown-core/concerns/liquid_renderable"
  autoload :LiquidRenderer,      "bridgetown-core/liquid_renderer"
  autoload :LogAdapter,          "bridgetown-core/log_adapter"
  autoload :PluginContentReader, "bridgetown-core/readers/plugin_content_reader"
  autoload :PluginManager,       "bridgetown-core/plugin_manager"
  autoload :Publishable,         "bridgetown-core/concerns/publishable"
  autoload :Publisher,           "bridgetown-core/publisher"
  autoload :Reader,              "bridgetown-core/reader"
  autoload :Renderer,            "bridgetown-core/renderer"
  autoload :RubyTemplateView,    "bridgetown-core/ruby_template_view"
  autoload :LogWriter,           "bridgetown-core/log_writer"
  autoload :Site,                "bridgetown-core/site"
  autoload :StaticFile,          "bridgetown-core/static_file"
  autoload :URL,                 "bridgetown-core/url"
  autoload :Utils,               "bridgetown-core/utils"
  autoload :VERSION,             "bridgetown-core/version"
  autoload :Watcher,             "bridgetown-core/watcher"
  autoload :YAMLParser,          "bridgetown-core/yaml_parser"

  # extensions
  require "bridgetown-core/commands/registrations"
  require "bridgetown-core/plugin"
  require "bridgetown-core/converter"
  require "bridgetown-core/generator"
  require "bridgetown-core/liquid_extensions"
  require "bridgetown-core/filters"

  require "bridgetown-core/drops/drop"
  require "bridgetown-core/drops/resource_drop"
  require_all "bridgetown-core/converters"
  require_all "bridgetown-core/converters/markdown"
  require_all "bridgetown-core/drops"
  require_all "bridgetown-core/generators"
  require_all "bridgetown-core/tags"
  require_all "bridgetown-core/core_ext"

  class << self
    # Tells you which Bridgetown environment you are building in so
    #   you can skip tasks if you need to.
    def environment
      (ENV["BRIDGETOWN_ENV"] || "development").inquiry
    end
    alias_method :env, :environment

    # Generate a Bridgetown configuration hash by merging the default
    #   options with anything in bridgetown.config.yml, and adding the given
    #   options on top.
    #
    # @param override [Hash] - A an optional hash of config directives that override
    #   any options in both the defaults and the config file. See
    #   {Bridgetown::Configuration::DEFAULTS} for a list of option names and their
    #   defaults.
    #
    # @return [Hash] The final configuration hash.
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

    # Conveinence method to register a new Thor command
    #
    # @see Bridgetown::Commands::Registrations.register
    def register_command(&block)
      Bridgetown::Commands::Registrations.register(&block)
    end

    def load_tasks
      require "bridgetown-core/commands/base"
      Bridgetown::PluginManager.require_from_bundler
      load File.expand_path("bridgetown-core/tasks/bridgetown_tasks.rake", __dir__)
    end

    # Determines the correct Bundler environment block method to use and passes
    # the block on to it.
    #
    # @return [void]
    def with_unbundled_env(&block)
      if Bundler.bundler_major_version >= 2
        Bundler.method(:with_unbundled_env).call(&block)
      else
        Bundler.method(:with_clean_env).call(&block)
      end
    end

    # Set the TZ environment variable to use the timezone specified
    #
    # @param timezone [String] the IANA Time Zone
    #
    # @return [void]
    # rubocop:disable Naming/AccessorMethodName
    def set_timezone(timezone)
      ENV["TZ"] = timezone
    end
    # rubocop:enable Naming/AccessorMethodName

    # Fetch the logger instance for this Bridgetown process.
    #
    # @return [LogAdapter]
    def logger
      @logger ||= LogAdapter.new(LogWriter.new, (ENV["BRIDGETOWN_LOG_LEVEL"] || :info).to_sym)
    end

    # Set the log writer. New log writer must respond to the same methods as Ruby's
    #   internal Logger.
    #
    # @param writer [Object] the new Logger-compatible log transport
    #
    # @return [LogAdapter]
    def logger=(writer)
      @logger = LogAdapter.new(writer, (ENV["BRIDGETOWN_LOG_LEVEL"] || :info).to_sym)
    end

    # Deprecated. Now using the Current site.
    #
    # @return [Array<Bridgetown::Site>] the Bridgetown sites created.
    def sites
      [Bridgetown::Current.site].compact
    end

    # Ensures the questionable path is prefixed with the base directory
    #   and prepends the questionable path with the base directory if false.
    #
    # @param base_directory [String] the directory with which to prefix the
    #   questionable path
    # @param questionable_path [String] the path we're unsure about, and want
    #   prefixed
    #
    # @return [String] the sanitized path
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
    Bridgetown::Utils::RequireGems.require_if_present("liquid/c")
  end
end

module Bridgetown
  module Model; end

  module Resource
    def self.register_extension(mod)
      if mod.const_defined?(:LiquidResource)
        Bridgetown::Drops::ResourceDrop.include mod.const_get(:LiquidResource)
      end
      if mod.const_defined?(:RubyResource) # rubocop:disable Style/GuardClause
        Bridgetown::Resource::Base.include mod.const_get(:RubyResource)
      end
    end
  end
end

# This method is available in Ruby 3, monkey patching for older versions
Psych.extend Bridgetown::CoreExt::Psych::SafeLoadFile unless Psych.respond_to?(:safe_load_file)

loader = Zeitwerk::Loader.new
loader.push_dir File.join(__dir__, "bridgetown-core/model"), namespace: Bridgetown::Model
loader.push_dir File.join(__dir__, "bridgetown-core/resource"), namespace: Bridgetown::Resource
loader.setup # ready!

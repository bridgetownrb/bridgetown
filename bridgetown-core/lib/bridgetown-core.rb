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
require "bundler/shared_helpers"

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
require "active_support/core_ext/class/attribute"
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
require "i18n/backend/fallbacks"
require "faraday"
require "thor"
require "zeitwerk"

# Ensure we can set up fallbacks so the default locale gets used
I18n::Backend::Simple.include I18n::Backend::Fallbacks

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
  autoload :Localizable,         "bridgetown-core/concerns/localizable"
  autoload :LiquidRenderer,      "bridgetown-core/liquid_renderer"
  autoload :LogAdapter,          "bridgetown-core/log_adapter"
  autoload :PluginContentReader, "bridgetown-core/readers/plugin_content_reader"
  autoload :PluginManager,       "bridgetown-core/plugin_manager"
  autoload :Prioritizable,       "bridgetown-core/concerns/prioritizable"
  autoload :Publishable,         "bridgetown-core/concerns/publishable"
  autoload :Reader,              "bridgetown-core/reader"
  autoload :RubyTemplateView,    "bridgetown-core/ruby_template_view"
  autoload :LogWriter,           "bridgetown-core/log_writer"
  autoload :Site,                "bridgetown-core/site"
  autoload :Slot,                "bridgetown-core/slot"
  autoload :StaticFile,          "bridgetown-core/static_file"
  autoload :Transformable,       "bridgetown-core/concerns/transformable"
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

  require "bridgetown-core/configuration"
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

    # Set up the Bridgetown execution environment before attempting to load any
    # plugins or gems prior to a site build
    def begin!
      ENV["RACK_ENV"] ||= environment

      Bridgetown::Current.preloaded_configuration = Bridgetown::Configuration::Preflight.new
      Bridgetown::PluginManager.setup_bundler
    end

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
      override = Configuration.new(override)
      unless override.delete("skip_config_files")
        config = config.read_config_files(config.config_files(override))
      end

      # Merge DEFAULTS < bridgetown.config.yml < override
      # @param obj [Bridgetown::Configuration]
      Configuration.from(Utils.deep_merge_hashes(config, override)).tap do |obj|
        set_timezone(obj["timezone"]) if obj["timezone"]

        # Copy "global" source manifests and initializers into this new configuration
        if Bridgetown::Current.preloaded_configuration.is_a?(Bridgetown::Configuration::Preflight)
          obj.source_manifests = Bridgetown::Current.preloaded_configuration.source_manifests

          if Bridgetown::Current.preloaded_configuration.initializers
            obj.initializers = Bridgetown::Current.preloaded_configuration.initializers
          end
        end

        Bridgetown::Current.preloaded_configuration = obj
      end
    end

    # Initialize a preflight configuration object, copying initializers and
    # source manifests from a previous standard configuration if necessary.
    # Typically only needed in test suites to reset before a new test.
    #
    # @return [Bridgetown::Configuration::Preflight]
    def reset_configuration! # rubocop:disable Metrics/AbcSize
      if Bridgetown::Current.preloaded_configuration.nil?
        return Bridgetown::Current.preloaded_configuration =
                 Bridgetown::Configuration::Preflight.new
      end

      return unless Bridgetown::Current.preloaded_configuration.is_a?(Bridgetown::Configuration)

      previous_config = Bridgetown::Current.preloaded_configuration
      new_config = Bridgetown::Configuration::Preflight.new
      new_config.initializers = previous_config.initializers
      new_config.source_manifests = previous_config.source_manifests
      if new_config.initializers
        new_config.initializers.delete(:init)
        new_config.initializers.select! do |_k, initializer|
          next false if initializer.block.source_location[0].start_with?(
            File.join(previous_config.root_dir, "config")
          )

          initializer.completed = false
          true
        end
      end

      Bridgetown::Current.preloaded_configuration = new_config
    end

    def initializer(name, prepend: false, replace: false, &block) # rubocop:todo Metrics
      unless Bridgetown::Current.preloaded_configuration
        raise "The `#{name}' initializer in #{block.source_location[0]} was called " \
              "without a preloaded configuration"
      end

      Bridgetown::Current.preloaded_configuration.initializers ||= {}

      if Bridgetown::Current.preloaded_configuration.initializers.key?(name.to_sym)
        if replace
          Bridgetown.logger.warn(
            "Initializing:",
            "The previous `#{name}' initializer was replaced by a new initializer"
          )
        else
          prev_block = Bridgetown::Current.preloaded_configuration.initializers[name.to_sym].block
          new_block = block
          block = if prepend
                    proc do |*args, **kwargs|
                      new_block.(*args, **kwargs)
                      prev_block.(*args, **kwargs)
                    end
                  else
                    proc do |*args, **kwargs|
                      prev_block.(*args, **kwargs)
                      new_block.(*args, **kwargs)
                    end
                  end
        end
      end

      Bridgetown::Current.preloaded_configuration.initializers[name.to_sym] =
        Bridgetown::Configuration::Initializer.new(
          name: name.to_sym,
          block: block,
          completed: false
        )
    end

    # @yieldself [Bridgetown::Configuration::ConfigurationDSL]
    def configure(&block)
      initializer :init, &block
    end

    # Convenience method to register a new Thor command
    #
    # @see Bridgetown::Commands::Registrations.register
    def register_command(&block)
      Bridgetown::Commands::Registrations.register(&block)
    end

    def load_tasks
      require "bridgetown-core/commands/base"
      unless Bridgetown::Current.preloaded_configuration
        Bridgetown::Current.preloaded_configuration = Bridgetown::Configuration::Preflight.new
      end
      Bridgetown::PluginManager.setup_bundler(skip_yarn: true)

      if Bridgetown::Current.preloaded_configuration.is_a?(Bridgetown::Configuration::Preflight)
        Bridgetown::Current.preloaded_configuration = Bridgetown.configuration
      end
      load File.expand_path("bridgetown-core/tasks/bridgetown_tasks.rake", __dir__)
    end

    # Loads ENV configuration via dotenv gem, if available
    #
    # @param root [String] root of Bridgetown site
    def load_dotenv(root:)
      dotenv_files = [
        File.join(root, ".env.#{Bridgetown.env}.local"),
        (File.join(root, ".env.local") unless Bridgetown.env.test?),
        File.join(root, ".env.#{Bridgetown.env}"),
        File.join(root, ".env"),
      ].compact
      Dotenv.load(*dotenv_files)
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

    # Get the current TZ environment variable
    #
    # @return [String]
    def timezone
      ENV["TZ"]
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
      Deprecator.deprecation_message(
        "Bridgetown.sites will be removed in the next version. Use Bridgetown::Current.sites" \
        "instead"
      )
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

    # When there's a build error, error details will be logged to a file which the dev server
    #   can read and pass along to the browser.
    #
    # @return [String] the path to the cached errors file
    def build_errors_path
      File.join(
        (Bridgetown::Current.site&.config || Bridgetown::Current.preloaded_configuration).root_dir,
        ".bridgetown-cache",
        "build_errors.txt"
      )
    end
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
Bridgetown::Model::Origin # this needs to load first

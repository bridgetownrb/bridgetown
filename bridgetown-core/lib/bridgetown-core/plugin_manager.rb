# frozen_string_literal: true

module Bridgetown
  class PluginManager
    LEGACY_PLUGINS_GROUP = :bridgetown_plugins
    YARN_DEPENDENCY_REGEXP = %r!(.+)@([^@]*)$!.freeze

    attr_reader :site, :loaders_manager

    @registered_plugins = Set.new

    # @param source_manifest [Bridgetown::Configuration::SourceManifest]
    def self.add_source_manifest(source_manifest)
      unless source_manifest.is_a?(Bridgetown::Configuration::SourceManifest)
        raise "You must add a SourceManifest instance"
      end

      unless Bridgetown::Current.preloaded_configuration
        raise "A preloaded configuration must be present before adding source manifests"
      end

      Bridgetown::Deprecator.deprecation_message(
        "The #{source_manifest.origin} plugin should switch from using `add_source_manifest' to " \
        "the `source_manifest` initializer method"
      )

      Bridgetown::Current.preloaded_configuration.source_manifests << source_manifest
    end

    def self.new_source_manifest(*_args, **kwargs)
      unless Bridgetown::Current.preloaded_configuration
        raise "A preloaded configuration must be present before adding source manifests"
      end

      Bridgetown::Deprecator.deprecation_message(
        "The #{kwargs[:origin]} plugin should switch from using `new_source_manifest' to the " \
        "`source_manifest` initializer method"
      )

      add_source_manifest(Bridgetown::Configuration::SourceManifest.new(**kwargs))
    end

    def self.add_registered_plugin(gem_or_plugin_file)
      @registered_plugins << gem_or_plugin_file
    end

    class << self
      attr_reader :registered_plugins

      def bundler_specs
        @bundler_specs ||= Bundler.load.requested_specs
      end

      def source_manifests
        Bridgetown::Deprecator.deprecation_message(
          "Use the configuration's `source_manifests` method instead of the plugin manager"
        )

        Bridgetown::Current.preloaded_configuration.source_manifests
      end
    end

    def self.setup_bundler(skip_yarn: false)
      if !ENV["BRIDGETOWN_NO_BUNDLER_REQUIRE"] &&
          (Bundler::SharedHelpers.in_bundle? || Bridgetown.env.test?)
        require "bundler"

        require_relative "utils/initializers"
        load_determined_bundler_environment(skip_yarn: skip_yarn)

        ENV["BRIDGETOWN_NO_BUNDLER_REQUIRE"] = "true"
        true
      else
        false
      end
    end
    class << self
      alias_method :require_from_bundler, :setup_bundler
    end

    def self.load_determined_bundler_environment(skip_yarn: false)
      boot_file = File.join("config", "boot.rb")

      if File.file?(boot_file)
        # We'll let config/boot.rb take care of Bundler setup
        require File.expand_path(boot_file)
      elsif File.file?(File.join("config", "initializers.rb"))
        # We'll just make sure the default and environmental gems are available.
        # Note: the default Bundler config will set up all gem groups,
        #   see: https://bundler.io/guides/groups.html
        Bundler.setup(:default, Bridgetown.env)
      else
        # Only setup and require :bridgetown_plugins
        legacy_yarn_and_register(legacy_require, skip_yarn: skip_yarn)
      end
    end

    def self.require_gem(name)
      Bridgetown::Utils::RequireGems.require_with_graceful_fail(name)
      plugins = Bridgetown::PluginManager.install_yarn_dependencies(name: name)

      plugin_to_register = if plugins.length == 1
                             plugins.first
                           else
                             bundler_specs.find do |loaded_gem|
                               loaded_gem.to_spec&.name == name.to_s
                             end
                           end
      add_registered_plugin plugin_to_register

      Bridgetown.logger.debug("PluginManager:",
                              "Registered #{plugin_to_register.name}")
    end

    def self.legacy_require
      Bundler.require(LEGACY_PLUGINS_GROUP).select do |dep|
        (dep.groups & [LEGACY_PLUGINS_GROUP]).any? && dep.should_include?
      end
    end

    def self.legacy_yarn_and_register(required_gems, skip_yarn: false)
      install_yarn_dependencies(required_gems) unless skip_yarn

      required_gems.each do |installed_gem|
        add_registered_plugin installed_gem
      end

      Bridgetown.logger.debug("PluginManager:",
                              "Required #{required_gems.map(&:name).join(", ")}")
    end

    def self.package_manager
      @package_manager ||= if File.exist?("yarn.lock")
                             "yarn"
                           elsif File.exist?("package-lock.json")
                             "npm"
                           elsif File.exist?("pnpm-lock.yaml")
                             "pnpm"
                           else
                             ""
                           end
    end

    def self.package_manager_install_command
      package_manager == "npm" ? "install" : "add"
    end

    # rubocop:disable Metrics/PerceivedComplexity, Metrics/CyclomaticComplexity

    # Iterates through loaded gems and finds yard-add gemspec metadata.
    # If that exact package hasn't been installed, execute yarn add
    #
    # @return [Bundler::SpecSet]
    def self.install_yarn_dependencies(required_gems = bundler_specs, name: nil)
      return required_gems unless File.exist?("package.json")

      package_json = JSON.parse(File.read("package.json"))

      gems_to_search = if name
                         required_gems.select do |loaded_gem|
                           loaded_gem.to_spec&.name == name.to_s
                         end
                       else
                         required_gems
                       end

      # all right, time to install the package
      gems_to_search.each do |loaded_gem|
        yarn_dependency = find_yarn_dependency(loaded_gem)
        next unless add_yarn_dependency?(yarn_dependency, package_json)

        next if package_manager.empty?

        cmd = "#{package_manager} #{package_manager_install_command} #{yarn_dependency.join("@")}"
        system cmd
      end

      gems_to_search
    end

    # rubocop:enable Metrics/PerceivedComplexity, Metrics/CyclomaticComplexity

    def self.find_yarn_dependency(loaded_gem)
      yarn_dependency = loaded_gem.to_spec&.metadata&.dig("yarn-add")&.match(YARN_DEPENDENCY_REGEXP)
      return nil if yarn_dependency&.length != 3 || yarn_dependency[2] == ""

      yarn_dependency[1..2]
    end

    def self.add_yarn_dependency?(yarn_dependency, package_json)
      return false if yarn_dependency.nil?

      # check matching version number is see if it's already installed
      if package_json["dependencies"]
        current_version = package_json["dependencies"][yarn_dependency.first]
        package_requires_updating?(current_version, yarn_dependency.last)
      else
        true
      end
    end

    def self.package_requires_updating?(current_version, dep_version)
      current_version.nil? || (current_version != dep_version && !current_version.include?("/"))
    end

    # Provides a plugin manager for the site
    #
    # @param site [Bridgetown::Site]
    def initialize(site)
      @site = site
    end

    # Finds and registers plugins in the local folder(s)
    #
    # @return [void]
    def require_plugin_files
      plugins_path.each do |plugin_search_path|
        plugin_files = Utils.safe_glob(plugin_search_path, File.join("**", "*.rb"))

        # Require "site_builder.rb" first if present so subclasses can all
        # inherit from SiteBuilder without needing explicit require statements
        sorted_plugin_files = plugin_files.select do |path|
          path.include?("site_builder.rb")
        end + plugin_files.reject do |path|
          path.include?("site_builder.rb")
        end

        sorted_plugin_files.each do |plugin_file|
          self.class.add_registered_plugin plugin_file
        end
      end
    end

    # Expands the path(s) of the plugins_dir config value
    #
    # @return [Array<String>] one or more plugin search paths
    def plugins_path
      if site.config["plugins_dir"].eql? Bridgetown::Configuration::DEFAULTS["plugins_dir"]
        [site.in_root_dir(site.config["plugins_dir"])]
      else
        Array(site.config["plugins_dir"]).map { |d| File.expand_path(d) }
      end
    end
  end
end

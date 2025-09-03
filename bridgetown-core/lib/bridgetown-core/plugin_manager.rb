# frozen_string_literal: true

module Bridgetown
  class PluginManager
    NPM_DEPENDENCY_REGEXP = %r!(.+)@([^@]*)$!

    attr_reader :site, :loaders_manager

    @registered_plugins = Set.new

    def self.add_registered_plugin(gem_or_plugin_file)
      @registered_plugins << gem_or_plugin_file
    end

    class << self
      attr_reader :registered_plugins

      def bundler_specs
        @bundler_specs ||= Bundler.load.requested_specs
      end
    end

    def self.setup_bundler
      if !ENV["BRIDGETOWN_NO_BUNDLER_REQUIRE"] &&
          (Bundler::SharedHelpers.in_bundle? || Bridgetown.env.test?)
        require "bundler"

        require_relative "utils/initializers"
        load_determined_bundler_environment
        require_plugin_features

        ENV["BRIDGETOWN_NO_BUNDLER_REQUIRE"] = "true"
        true
      else
        false
      end
    end
    class << self
      alias_method :require_from_bundler, :setup_bundler
    end

    def self.load_determined_bundler_environment
      boot_file = File.join("config", "boot.rb")

      if File.file?(boot_file)
        # We'll let config/boot.rb take care of Bundler setup
        require File.expand_path(boot_file)
      elsif File.file?(File.join("config", "initializers.rb"))
        # We'll just make sure the default and environmental gems are available.
        # Note: the default Bundler config will set up all gem groups,
        #   see: https://bundler.io/guides/groups.html
        Bundler.setup(:default, Bridgetown.env)
      end
    end

    def self.require_plugin_features
      bundler_specs.select do |loaded_gem|
        loaded_gem.to_spec.metadata["bridgetown_features"] == "true"
      end.each do |plugin_gem|
        Bridgetown::Utils::RequireGems.require_with_graceful_fail(
          "bridgetown/features/#{plugin_gem.name}"
        )
      end
    end

    def self.require_gem(name)
      Bridgetown::Utils::RequireGems.require_with_graceful_fail(name)
      plugins = Bridgetown::PluginManager.install_npm_dependencies(name:)

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

    def self.package_manager
      @package_manager ||= if File.exist?("yarn.lock")
                             "yarn"
                           elsif File.exist?("pnpm-lock.yaml")
                             "pnpm"
                           elsif File.exist?("package.json")
                             "npm"
                           else
                             ""
                           end
    end

    def self.package_manager_install_command
      package_manager == "npm" ? "install" : "add"
    end

    def self.package_manager_uninstall_command
      package_manager == "npm" ? "uninstall" : "remove"
    end

    # rubocop:disable Metrics/PerceivedComplexity, Metrics/CyclomaticComplexity

    # Iterates through loaded gems and finds npm_add gemspec metadata.
    # If that exact package hasn't been installed, execute npm i
    #
    # @return [Bundler::SpecSet]
    def self.install_npm_dependencies(required_gems = bundler_specs, name: nil)
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
        npm_dependency = find_npm_dependency(loaded_gem)
        next unless add_npm_dependency?(npm_dependency, package_json)

        next if package_manager.empty?

        cmd = "#{package_manager} #{package_manager_install_command} #{npm_dependency.join("@")}"
        system cmd
      end

      gems_to_search
    end

    def self.find_npm_dependency(loaded_gem)
      npm_metadata = loaded_gem.to_spec&.metadata&.dig("npm_add") ||
        loaded_gem.to_spec&.metadata&.dig("yarn-add")
      npm_dependency = npm_metadata&.match(NPM_DEPENDENCY_REGEXP)
      return nil if npm_dependency&.length != 3 || npm_dependency[2] == ""

      npm_dependency[1..2]
    end

    # rubocop:enable Metrics/PerceivedComplexity, Metrics/CyclomaticComplexity

    def self.add_npm_dependency?(npm_dependency, package_json)
      return false if npm_dependency.nil?

      # check matching version number is see if it's already installed
      if package_json["dependencies"]
        current_version = package_json["dependencies"][npm_dependency.first]
        current_version = current_version.delete_prefix("^") if current_version
        package_requires_updating?(current_version, npm_dependency.last)
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

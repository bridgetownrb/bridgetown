# frozen_string_literal: true

module Bridgetown
  class PluginManager
    attr_reader :site

    @source_manifests = Set.new
    @registered_plugins = Set.new

    def self.add_source_manifest(source_manifest)
      unless source_manifest.is_a?(Bridgetown::Plugin::SourceManifest)
        raise "You must add a SourceManifest instance"
      end

      @source_manifests << source_manifest
    end

    def self.new_source_manifest(*args)
      add_source_manifest(Bridgetown::Plugin::SourceManifest.new(*args))
    end

    def self.add_registered_plugin(gem_or_plugin_file)
      @registered_plugins << gem_or_plugin_file
    end

    class << self
      attr_reader :source_manifests, :registered_plugins
    end

    # Create an instance of this class.
    #
    # site - the instance of Bridgetown::Site we're concerned with
    #
    # Returns nothing
    def initialize(site)
      @site = site
    end

    def self.require_from_bundler
      if !ENV["BRIDGETOWN_NO_BUNDLER_REQUIRE"] && File.file?("Gemfile")
        require "bundler"

        group_name = :bridgetown_plugins

        required_gems = Bundler.require group_name
        required_gems.select! do |dep|
          (dep.groups & [group_name]).any? && dep.should_include?
        end

        install_yarn_dependencies(required_gems)

        required_gems.each do |installed_gem|
          add_registered_plugin installed_gem
        end

        Bridgetown.logger.debug("PluginManager:",
                                "Required #{required_gems.map(&:name).join(", ")}")
        ENV["BRIDGETOWN_NO_BUNDLER_REQUIRE"] = "true"

        true
      else
        false
      end
    end

    # Iterates through loaded plugins and finds yard-add gemspec metadata.
    # If that exact package hasn't been installed, execute yarn add
    #
    # Returns nothing.
    def self.install_yarn_dependencies(required_gems)
      return unless File.exist?("package.json")

      package_json = JSON.parse(File.read("package.json"))

      required_gems.each do |loaded_gem|
        next unless loaded_gem.to_spec&.metadata&.dig("yarn-add")

        yarn_add_dependency = loaded_gem.to_spec.metadata["yarn-add"].split("@")
        next unless yarn_add_dependency.length == 2

        # check matching version number is see if it's already installed
        current_package = package_json["dependencies"].dig(yarn_add_dependency.first)
        next unless current_package.nil? || current_package != yarn_add_dependency.last

        # all right, time to install the package
        cmd = "yarn add #{yarn_add_dependency.join("@")}"
        system cmd
      end
    end

    # Require all .rb files
    #
    # Returns nothing.
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
        Bridgetown::External.require_with_graceful_fail(sorted_plugin_files)
      end
    end

    # Reload .rb plugin files via the watcher
    def reload_plugin_files
      plugins_path.each do |plugin_search_path|
        plugin_files = Utils.safe_glob(plugin_search_path, File.join("**", "*.rb"))
        Array(plugin_files).each do |name|
          Bridgetown.logger.debug "Reloading:", name.to_s
          self.class.add_registered_plugin name
          load name
        end
      end
    end

    # Public: Setup the plugin search path
    #
    # Returns an Array of plugin search paths
    def plugins_path
      if site.config["plugins_dir"].eql? Bridgetown::Configuration::DEFAULTS["plugins_dir"]
        [site.in_root_dir(site.config["plugins_dir"])]
      else
        Array(site.config["plugins_dir"]).map { |d| File.expand_path(d) }
      end
    end
  end
end

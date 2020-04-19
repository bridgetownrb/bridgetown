# frozen_string_literal: true

module Bridgetown
  class PluginManager
    attr_reader :site

    # Create an instance of this class.
    #
    # site - the instance of Bridgetown::Site we're concerned with
    #
    # Returns nothing
    def initialize(site)
      @site = site
    end

    # Require all the plugins which are allowed.
    #
    # Returns nothing
    def conscientious_require
      require_plugin_files
    end

    def self.require_from_bundler
      if !ENV["BRIDGETOWN_NO_BUNDLER_REQUIRE"] && File.file?("Gemfile")
        require "bundler"

        Bundler.setup
        required_gems = Bundler.require(:bridgetown_plugins)
        install_yarn_dependencies(required_gems)
        message = "Required #{required_gems.map(&:name).join(", ")}"
        Bridgetown.logger.debug("PluginManager:", message)
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
        Bridgetown::External.require_with_graceful_fail(plugin_files)
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

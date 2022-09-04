# frozen_string_literal: true

module Bridgetown
  module Commands
    class Clean < Thor::Group
      extend BuildOptions
      extend Summarizable
      include ConfigurationOverridable

      Registrations.register do
        register(Clean, "clean", "clean", Clean.summary)
      end

      def self.banner
        "bridgetown clean [options]"
      end
      summary "Clean the site (removes site output and metadata file) without building"

      def clean
        config = configuration_with_overrides(options, Bridgetown::Current.preloaded_configuration)
        destination = config["destination"]
        metadata_file = File.join(config["root_dir"], ".bridgetown-metadata")
        cache_dir = File.join(config["root_dir"], config["cache_dir"])
        bundling_dir = File.join(config["root_dir"], ".bridgetown-cache", "frontend-bundling")

        remove(destination, checker_func: :directory?)
        remove(metadata_file, checker_func: :file?)
        remove(cache_dir, checker_func: :directory?)
        remove(bundling_dir, checker_func: :directory?)
      end

      protected

      def remove(filename, checker_func: :file?)
        if File.public_send(checker_func, filename)
          Bridgetown.logger.info "Cleaner:", "Removing #{filename}..."
          FileUtils.rm_rf(filename)
        else
          Bridgetown.logger.info "Cleaner:", "Nothing to do for #{filename}."
        end
      end
    end
  end
end

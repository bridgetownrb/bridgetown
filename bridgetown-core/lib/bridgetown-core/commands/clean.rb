# frozen_string_literal: true

module Bridgetown
  module Commands
    class Clean < Thor::Group
      Registrations.register do
        register(Clean, "clean", "clean", Clean.summary)
      end

      extend BuildOptions
      extend Summarizable
      include OptionsConfigurable

      def self.banner
        "bridgetown clean [options]"
      end

      summary "Clean the site (removes site output and metadata file) without building"

      def clean
        config = configuration_from_options(options)
        destination = config["destination"]
        metadata_file = File.join(config["root_dir"], ".bridgetown-metadata")
        cache_dir = File.join(config["root_dir"], config["cache_dir"])
        webpack_dir = File.join(config["root_dir"], ".bridgetown-webpack")

        remove(destination, checker_func: :directory?)
        remove(metadata_file, checker_func: :file?)
        remove(cache_dir, checker_func: :directory?)
        remove(webpack_dir, checker_func: :directory?)
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

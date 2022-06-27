# frozen_string_literal: true

module Bridgetown
  module Commands
    module BuildOptions
      def self.extended(klass)
        klass.class_option :trace,
                           type: :boolean,
                           aliases: "-t",
                           desc: "Show the full backtrace when an error occurs during watch mode"

        klass.class_option :config,
                           type: :array,
                           banner: "FILE1 FILE2",
                           desc: "Custom configuration file(s)"
        klass.class_option :source,
                           aliases: "-s",
                           desc: "Source directory (defaults to src)"
        klass.class_option :destination,
                           aliases: "-d",
                           desc: "Destination directory (defaults to output)"
        klass.class_option :root_dir,
                           aliases: "-r",
                           desc: "The top-level root folder " \
                                 "where config files are located"
        klass.class_option :plugins_dir,
                           aliases: "-p",
                           type: :array,
                           banner: "DIR1 DIR2",
                           desc: "Plugins directory (defaults to plugins)"
        klass.class_option :layouts_dir,
                           desc: "Layouts directory (defaults to src/_layouts)"
        klass.class_option :future,
                           type: :boolean,
                           desc: "Publishes posts with a future date"
        klass.class_option :url,
                           aliases: "-u",
                           desc: "Override the configured url for the website"
        klass.class_option :base_path,
                           aliases: "-b",
                           desc: "Serve the website from the given base path"
        klass.class_option :force_polling,
                           type: :boolean,
                           desc: "Force watch to use polling"
        klass.class_option :unpublished,
                           type: :boolean,
                           aliases: "-U",
                           desc: "Render posts that were marked as unpublished"
        klass.class_option :disable_disk_cache,
                           type: :boolean,
                           desc: "Disable caching to disk"
        klass.class_option :profile,
                           type: :boolean,
                           desc: "Generate a Liquid rendering profile"
        klass.class_option :quiet,
                           aliases: "-q",
                           type: :boolean,
                           desc: "Silence output."
        klass.class_option :verbose,
                           aliases: "-V",
                           type: :boolean,
                           desc: "Print verbose output."
        klass.class_option :strict_front_matter,
                           type: :boolean,
                           desc: "Fail if errors are present in front matter"
      end
    end
  end
end

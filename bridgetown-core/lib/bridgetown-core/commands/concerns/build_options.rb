# frozen_string_literal: true

module Bridgetown
  module Commands
    module BuildOptions
      def self.include_options(klass) # rubocop:disable Metrics/MethodLength
        klass.option "-t/--trace", "Show the full backtrace when an error occurs during watch mode"
        klass.option "--config <FILE1,FILE2>", "Custom configuration file(s)" do |value|
          value.split(%r{\s*,\s*})
        end
        klass.option "-s/--source <SOURCE>", "Source directory (defaults to src)"
        klass.option "-d/--destination <DESTINATION>", "Destination directory (defaults to output)"
        klass.option "-r/--root-dir <DIR>", "The top-level root folder " \
                                            "where config files are located"
        klass.option "-p/--plugins-dir <DIR1,DIR2>",
                     "Plugins directory (defaults to plugins)" do |value|
          value.split(%r{\s*,\s*})
        end
        klass.option "--layouts-dir <DIR>", "Layouts directory (defaults to src/_layouts)"
        klass.option "--future", "Publishes posts with a future date"
        klass.option "-u/--url <URL>", "Override the configured url for the website"
        klass.option "-b/--base-path", "Serve the website from the given base path"
        klass.option "--force-polling", "Force watch to use polling"
        klass.option "-U/--unpublished", "Render posts that were marked as unpublished"
        klass.option "--disable-disk-cache", "Disable caching to disk"
        klass.option "--profile", "Generate a Liquid rendering profile"
        klass.option "-q/--quiet", "Silence output"
        klass.option "-V/--verbose", "Print verbose output"
        klass.option "--strict-front-matter", "Fail if errors are present in front matter"
      end
    end
  end
end

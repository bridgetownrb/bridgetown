# frozen_string_literal: true

require "erb"

module Bridgetown
  module Commands
    class New < Thor::Group
      Registrations.register do
        register(New, "new", "new PATH", New.summary)
      end

      extend Summarizable

      class_option :apply,
                   aliases: "-a",
                   banner: "PATH|URL",
                   desc: "Apply an automation after creating the site scaffold"
      class_option :force,
                   type: :boolean,
                   desc: "Force creation even if PATH already exists"
      class_option :"skip-bundle",
                   type: :boolean,
                   desc: "Skip 'bundle install'"
      class_option :"skip-yarn",
                   type: :boolean,
                   desc: "Skip 'yarn install'"

      def self.banner
        "bridgetown new PATH"
      end

      summary "Creates a new Bridgetown site scaffold in PATH"

      DOCSURL = "https://bridgetownrb.com/docs"

      class << self
        attr_accessor :created_site_dir
      end

      def new_site_path
        raise ArgumentError, "You must specify a path." if args.empty?

        new_site_path = File.expand_path(args.join(" "), Dir.pwd)
        FileUtils.mkdir_p new_site_path
        if preserve_source_location?(new_site_path, options)
          Bridgetown.logger.error "Conflict:", "#{new_site_path} exists and is not empty."
          Bridgetown.logger.abort_with "", "Ensure #{new_site_path} is empty or else " \
                    "try again with `--force` to proceed and overwrite any files."
        end

        Bridgetown.logger.info("Creating:".green, new_site_path)

        create_site new_site_path

        self.class.created_site_dir = new_site_path

        after_install(new_site_path, args.join(" "), options)
      end

      protected

      def scaffold_post_content
        ERB.new(File.read(File.expand_path(scaffold_path, site_template))).result
      end

      # Internal: Gets the filename of the sample post to be created
      #
      # Returns the filename of the sample post, as a String
      def initialized_post_name
        "src/_posts/#{Time.now.strftime("%Y-%m-%d")}-welcome-to-bridgetown.md"
      end

      private

      def gemfile_contents
        <<~RUBY
          source "https://rubygems.org"
          # Hello! This is where you manage which Bridgetown version is used to run.
          # When you want to use a different version, change it below, save the
          # file and run `bundle install`. Run Bridgetown with `bundle exec`, like so:
          #
          #   bundle exec bridgetown serve
          #
          # This will help ensure the proper Bridgetown version is running.
          #
          # To install a plugin, simply run bundle add and specify the group
          # "bridgetown_plugins". For example:
          #
          #   bundle add some-new-plugin -g bridgetown_plugins
          #
          # Happy Bridgetowning!

          gem "bridgetown", "~> #{Bridgetown::VERSION}"

        RUBY
      end

      def create_site(new_site_path)
        create_sample_files new_site_path

        File.open(File.expand_path(initialized_post_name, new_site_path), "w") do |f|
          f.write(scaffold_post_content)
        end

        File.open(File.expand_path("Gemfile", new_site_path), "w") do |f|
          f.write(gemfile_contents)
        end
      end

      def preserve_source_location?(path, options)
        !options["force"] && !Dir["#{path}/**/*"].empty?
      end

      def create_sample_files(path)
        FileUtils.cp_r site_template + "/.", path
        FileUtils.chmod_R "u+w", path
        FileUtils.rm File.expand_path(scaffold_path, path)
      end

      def site_template
        File.expand_path("../../site_template", __dir__)
      end

      def scaffold_path
        "src/_posts/0000-00-00-welcome-to-bridgetown.md.erb"
      end

      # After a new site has been created, print a success notification and
      # then automatically execute bundle install from within the new site dir
      # unless the user opts to skip 'bundle install'.
      def after_install(path, cli_path, options = {})
        logger = Bridgetown.logger
        git_init path

        unless options["skip-bundle"]
          begin
            require "bundler"
            bundle_install path
          rescue LoadError
            logger.info "Could not load Bundler. Bundle install skipped."
          end
        end

        yarn_install path unless options["skip-yarn"]

        invoke(Apply, [], options) if options[:apply]

        yarn_start = "yarn start"

        logger.info "Success!".green, "🎉 Your new Bridgetown site was" \
                    " generated in #{cli_path.cyan}."
        if options["skip-yarn"]
          logger.info "You can now #{"cd".cyan} #{cli_path.cyan} to get started."
          logger.info "You'll probably also want to #{"yarn install".cyan}" \
                      " to load in your frontend assets."
        else
          logger.info "You can now #{"cd".cyan} and run #{yarn_start.cyan} to get started."
        end
        logger.info "Then check out our online documentation for" \
                    " next steps: #{DOCSURL.cyan}"
        logger.info "Bundle install skipped." if options["skip-bundle"]
      end
      # rubocop:enable#

      def bundle_install(path)
        Bridgetown.logger.info "Running bundle install in #{path.cyan}..."
        Dir.chdir(path) do
          exe = Gem.bin_path("bundler", "bundle")
          process, output = Bridgetown::Utils::Exec.run("ruby", exe, "install")

          output.to_s.each_line do |line|
            Bridgetown.logger.info("Bundler:".green, line.strip) unless line.to_s.empty?
          end

          raise SystemExit unless process.success?
        end
      end

      def git_init(path)
        Dir.chdir(path) do
          _process, output = Bridgetown::Utils::Exec.run("git", "init")
          output.to_s.each_line do |line|
            Bridgetown.logger.info("Git:".green, line.strip) unless line.to_s.empty?
          end
        end
      rescue SystemCallError
      end

      def yarn_install(path)
        Bridgetown.logger.info "Running yarn install in #{path.cyan}..."
        Dir.chdir(path) do
          _process, output = Bridgetown::Utils::Exec.run("yarn", "install")
          output.to_s.each_line do |line|
            next if line.to_s.empty? ||
              line.strip.start_with?("warning ") ||
              line.include?("No lockfile found")

            Bridgetown.logger.info("Yarn:".green, line.strip)
          end
        end
      rescue SystemCallError
        Bridgetown.logger.info "Could not load yarn. yarn install skipped."
      end
    end
  end
end

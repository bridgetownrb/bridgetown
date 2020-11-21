# frozen_string_literal: true

module Bridgetown
  module Commands
    class New < Thor::Group
      include Thor::Actions
      extend Summarizable

      Registrations.register do
        register(New, "new", "new PATH", New.summary)
      end

      def self.banner
        "bridgetown new PATH"
      end
      summary "Creates a new Bridgetown site scaffold in PATH"

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

      DOCSURL = "https://bridgetownrb.com/docs"

      def self.exit_on_failure?
        false
      end

      def self.source_root
        File.expand_path("../../site_template", __dir__)
      end

      class << self
        attr_accessor :created_site_dir
      end

      def new_site
        raise ArgumentError, "You must specify a path." if args.empty?

        new_site_path = File.expand_path(args.join(" "), Dir.pwd)
        @site_name = new_site_path.split(File::SEPARATOR).last

        if preserve_source_location?(new_site_path, options)
          say_status :conflict, "#{new_site_path} exists and is not empty.", :red
          Bridgetown.logger.abort_with "Ensure #{new_site_path} is empty or else " \
                    "try again with `--force` to proceed and overwrite any files."
        end

        self.destination_root = self.class.created_site_dir = new_site_path

        say_status :create, new_site_path
        create_site new_site_path
        after_install new_site_path, args.join(" "), options
      end

      protected

      def preserve_source_location?(path, options)
        !options["force"] && Dir.exist?(path)
      end

      def create_site(new_site_path)
        directory ".", ".", exclude_pattern: %r!\.erb|DS_Store$!
        FileUtils.chmod_R "u+w", new_site_path

        template(
          "src/_posts/0000-00-00-welcome-to-bridgetown.md.erb",
          "src/_posts/#{Time.now.strftime("%Y-%m-%d")}-welcome-to-bridgetown.md"
        )
        template("Gemfile.erb", "Gemfile")
        template("package.json.erb", "package.json")
      end

      # After a new site has been created, print a success notification and
      # then automatically execute bundle install from within the new site dir
      # unless the user opts to skip 'bundle install'.
      # rubocop:todo Metrics/CyclomaticComplexity
      def after_install(path, cli_path, options = {})
        git_init path

        @skipped_bundle = true # is set to false if bundle install worked
        bundle_install path unless options["skip-bundle"]

        @skipped_yarn = true
        yarn_install path unless options["skip-yarn"]

        invoke(Apply, [], options) if options[:apply]

        logger = Bridgetown.logger
        yarn_start = "yarn start"
        logger.info ""
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

        logger.info "Bundle install skipped.".yellow if @skipped_bundle
        logger.info "Yarn install skipped.".yellow if @skipped_yarn
      end
      # rubocop:enable Metrics/CyclomaticComplexity

      def bundle_install(path)
        unless Bridgetown.environment == "test"
          require "bundler"
          Bridgetown.with_unbundled_env do
            inside(path) do
              run "bundle install", abort_on_failure: true
            end
          end
        end
        @skipped_bundle = false
      rescue LoadError
        say_status :run, "Could not load Bundler. Bundle install skipped.", :red
      rescue SystemExit
        say_status :run, "Problem occured while running bundle install.", :red
      end

      def git_init(path)
        unless Bridgetown.environment == "test"
          inside(path) do
            run "git init", abort_on_failure: true
          end
        end
      rescue SystemExit
        say_status :run, "Could not load git. git init skipped.", :red
      end

      def yarn_install(path)
        unless Bridgetown.environment == "test"
          inside(path) do
            run "yarn install", abort_on_failure: true
          end
        end
        @skipped_yarn = false
      rescue SystemExit
        say_status :run, "Could not load yarn. yarn install skipped.", :red
      end
    end
  end
end

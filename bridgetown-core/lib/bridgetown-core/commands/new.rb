# frozen_string_literal: true

module Bridgetown
  module Commands
    class New < Samovar::Command
      using Bridgetown::Refinements
      include Freyia::Setup
      include Automations
      include GitHelpers

      Registrations.register New, "new"

      self.description = "Creates a new Bridgetown site scaffold in PATH"

      one :path, "where new Bridgetown site will be created", required: true

      options do
        option "-a/--apply <PATH|URL>", "Apply an automation after creating the site scaffold"
        option "-c/--configure <CONFIGURATION(S)>",
               "Comma separated list of bundled configurations to perform"
        option "-h/--help", "Print help for the new command"
        option "-t/--templates <erb|serbea|liquid>", "Preferred template engine (defaults to ERB)"
        option "--force", "Force creation even if PATH already exists"
        option "--skip-bundle", "Skip 'bundle install'"
        option "--skip-npm", "Skip 'npm install'"
        option "--use-sass", "Set up a Sass configuration for your stylesheet"
      end

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

      def call # rubocop:disable Metrics
        case path
        when "--help", "-help", "-h"
          print_usage
          return
        end

        self.source_paths = [self.class.source_root]

        new_site_path = File.expand_path(path, Dir.pwd)
        @site_name = new_site_path.split(File::SEPARATOR).last

        if preserve_source_location?(new_site_path, options)
          say_status :conflict, "#{new_site_path} exists and is not empty.", :red
          Bridgetown.logger.abort_with(
            "Ensure #{new_site_path} is empty or else try again with `--force` to proceed and " \
            "overwrite any files."
          )
        end

        self.destination_root = self.class.created_site_dir = new_site_path

        say_status :create, new_site_path
        create_site new_site_path
        after_install new_site_path, path, options
      rescue ArgumentError => e
        say_status :alert, e.message, :red
      ensure
        self.class.created_site_dir = nil # reset afterwards, otherwise hanging tmp dirs in test
      end

      protected

      def preserve_source_location?(path, options)
        !options[:force] && Dir.exist?(path)
      end

      def frontend_bundling_option
        "esbuild"
      end

      def postcss_option # rubocop:disable Naming/PredicateMethod
        !options[:use_sass]
      end

      def disable_postcss?
        # TODO: add option not to use postcss/sass at all
        false
      end

      def create_site(new_site_dir) # rubocop:disable Metrics
        directory ".", ".", exclude_pattern: %r!\.erb|TEMPLATES|DS_Store$|\.(s[ac]|c)ss$!
        FileUtils.chmod_R "u+w", new_site_dir

        template(
          "src/_posts/0000-00-00-welcome-to-bridgetown.md.erb",
          "src/_posts/#{Time.now.strftime("%Y-%m-%d")}-welcome-to-bridgetown.md"
        )
        template("ruby-version.erb", ".ruby-version")
        template("Gemfile.erb", "Gemfile")
        template("Rakefile.erb", "Rakefile")
        template("package.json.erb", "package.json")
        template("frontend/javascript/index.js.erb", "frontend/javascript/index.js")
        template("src/index.md.erb", "src/index.md")
        template("src/posts.md.erb", "src/posts.md")
        copy_file("frontend/styles/syntax-highlighting.css")

        case options[:templates]
        when "serbea"
          setup_serbea_templates
        when "liquid"
          setup_liquid_templates
        else # default if no option specififed
          setup_erb_templates
        end

        postcss_option ? configure_postcss : configure_sass

        return unless frontend_bundling_option == "esbuild"

        Esbuild["setup"].(new_site_dir:)
      end

      def setup_erb_templates
        directory "TEMPLATES/erb/_layouts", "src/_layouts"
        directory "TEMPLATES/erb/_components", "src/_components"
        directory "TEMPLATES/erb/_partials", "src/_partials"
      end

      def setup_serbea_templates
        directory "TEMPLATES/serbea/_layouts", "src/_layouts"
        directory "TEMPLATES/serbea/_components", "src/_components"
        directory "TEMPLATES/serbea/_partials", "src/_partials"
        gsub_file "config/initializers.rb", %r!template_engine "erb"\n!, <<~RUBY
          template_engine "serbea"
        RUBY
      end

      def setup_liquid_templates
        directory "TEMPLATES/liquid/_layouts", "src/_layouts"
        directory "TEMPLATES/liquid/_components", "src/_components"
        gsub_file "config/initializers.rb", %r!template_engine "erb"\n!, <<~RUBY
          template_engine "liquid"
        RUBY
      end

      def configure_sass
        template("postcss.config.js.erb", "postcss.config.js") unless disable_postcss?
        copy_file("frontend/styles/index.css", "frontend/styles/index.scss")
      end

      def configure_postcss
        template("postcss.config.js.erb", "postcss.config.js") unless disable_postcss?
        copy_file("frontend/styles/index.css")
      end

      # After a new site has been created, print a success notification and
      # then automatically execute bundle install from within the new site dir
      # unless the user opts to skip 'bundle install'.
      def after_install(path, cli_path, options) # rubocop:disable Metrics
        git_init path

        @skipped_bundle = true # is set to false if bundle install worked
        bundle_install path unless options[:skip_bundle]

        @skipped_npm = true
        npm_install path unless options[:skip_npm]

        Apply[options[:apply]].(new_site_dir: path) if options[:apply]
        Configure[*options[:configure].split(",")].(new_site_dir: path) if options[:configure]

        logger = Bridgetown.logger
        bt_start = "bin/bridgetown start"
        logger.info ""
        logger.info "Success!".green, "🎉 Your new Bridgetown site was " \
                                      "generated in #{cli_path.cyan}."
        if options["skip-npm"]
          logger.info "You can now #{"cd".cyan} #{cli_path.cyan} to get started."
          logger.info "You'll probably also want to #{"npm install".cyan} " \
                      "to load in your frontend assets."
        else
          logger.info "You can now #{"cd".cyan} #{cli_path.cyan} and run #{bt_start.cyan} " \
                      "to get started."
        end
        logger.info "Then check out our online documentation for " \
                    "next steps: #{DOCSURL.cyan}"

        if @skipped_bundle
          logger.info "Bundle install skipped.".yellow
          logger.info "You will need to run #{"bundle binstubs bridgetown-core".cyan} manually."
        end

        logger.info "NPM install skipped.".yellow if @skipped_npm
      end

      def bundle_install(path)
        unless Bridgetown.environment.test?
          require "bundler"
          Bridgetown.with_unbundled_env do
            inside(path) do
              run "bundle install", abort_on_failure: true
              # create binstubs to `bin/bridgetown` and `bin/bt`
              run "bundle binstubs bridgetown-core"
            end
          end
        end
        @skipped_bundle = false
      rescue LoadError
        say_status :alert, "Could not load Bundler. Bundle install skipped.", :red
      rescue SystemExit
        say_status :alert, "Problem occured while running bundle install.", :red
      end

      def git_init(path)
        unless Bridgetown.environment.test?
          inside(path) do
            initialize_new_repo
          end
        end
      rescue SystemExit
        say_status :alert, "Could not load git. git init skipped.", :red
      end

      def npm_install(path)
        unless Bridgetown.environment.test?
          inside(path) do
            run "npm install", abort_on_failure: true
          end
        end
        @skipped_npm = false
      rescue SystemExit
        say_status :alert, "Could not load npm. NPM install skipped.", :red
      end
    end
  end
end

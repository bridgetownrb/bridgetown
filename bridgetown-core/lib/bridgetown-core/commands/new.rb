# frozen_string_literal: true

module Bridgetown
  module Commands
    class New < Thor::Group
      include Thor::Actions
      include GitHelpers
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
      class_option :configure,
                   aliases: "-c",
                   banner: "CONFIGURATION(S)",
                   desc: "Comma separated list of bundled configurations to perform"
      class_option :templates,
                   aliases: "-t",
                   banner: "liquid|erb|serbea",
                   desc: "Preferred template engine (defaults to Liquid)"
      class_option :"frontend-bundling",
                   aliases: "-e",
                   banner: "esbuild",
                   desc: "Choose frontend bundling stack (defaults to esbuild)"
      class_option :force,
                   type: :boolean,
                   desc: "Force creation even if PATH already exists"
      class_option :"skip-bundle",
                   type: :boolean,
                   desc: "Skip 'bundle install'"
      class_option :"skip-yarn",
                   type: :boolean,
                   desc: "Skip 'yarn install'"
      class_option :"use-sass",
                   type: :boolean,
                   desc: "Set up a Sass configuration for your stylesheet"

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
          Bridgetown.logger.abort_with(
            "Ensure #{new_site_path} is empty or else try again with `--force` to proceed and " \
            "overwrite any files."
          )
        end

        self.destination_root = self.class.created_site_dir = new_site_path

        say_status :create, new_site_path
        create_site new_site_path
        after_install new_site_path, args.join(" "), options
      rescue ArgumentError => e
        say_status :alert, e.message, :red
      ensure
        self.class.created_site_dir = nil # reset afterwards, otherwise hanging tmp dirs in test
      end

      protected

      def preserve_source_location?(path, options)
        !options["force"] && Dir.exist?(path)
      end

      def frontend_bundling_option
        "esbuild"
      end

      def postcss_option
        !options["use-sass"]
      end

      def disable_postcss?
        # TODO: add option not to use postcss/sass at all
        false
      end

      def create_site(new_site_path)
        directory ".", ".", exclude_pattern: %r!\.erb|TEMPLATES|DS_Store$|\.(s[ac]|c)ss$!
        FileUtils.chmod_R "u+w", new_site_path

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

        case options["templates"]
        when "erb"
          setup_erb_templates
        when "serbea"
          setup_serbea_templates
        else
          setup_liquid_templates
        end

        postcss_option ? configure_postcss : configure_sass

        return unless frontend_bundling_option == "esbuild"

        invoke(Esbuild, ["setup"], {})
      end

      def setup_erb_templates
        directory "TEMPLATES/erb/_layouts", "src/_layouts"
        directory "TEMPLATES/erb/_components", "src/_components"
        directory "TEMPLATES/erb/_partials", "src/_partials"
        gsub_file "bridgetown.config.yml", %r!permalink: pretty\n!, <<~YML
          permalink: pretty
          template_engine: erb
        YML
      end

      def setup_serbea_templates
        directory "TEMPLATES/serbea/_layouts", "src/_layouts"
        directory "TEMPLATES/serbea/_components", "src/_components"
        directory "TEMPLATES/serbea/_partials", "src/_partials"
        gsub_file "bridgetown.config.yml", %r!permalink: pretty\n!, <<~YML
          permalink: pretty
          template_engine: serbea
        YML
      end

      def setup_liquid_templates
        directory "TEMPLATES/liquid/_layouts", "src/_layouts"
        directory "TEMPLATES/liquid/_components", "src/_components"
        gsub_file "bridgetown.config.yml", %r!permalink: pretty\n!, <<~YML
          permalink: pretty
          template_engine: liquid
        YML
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
      # rubocop:todo Metrics/CyclomaticComplexity
      # rubocop:disable Metrics/PerceivedComplexity
      def after_install(path, cli_path, options = {})
        git_init path

        @skipped_bundle = true # is set to false if bundle install worked
        bundle_install path unless options["skip-bundle"]

        @skipped_yarn = true
        yarn_install path unless options["skip-yarn"]

        invoke(Apply, [], options) if options[:apply]
        invoke(Configure, options[:configure].split(","), {}) if options[:configure]

        logger = Bridgetown.logger
        bt_start = "bin/bridgetown start"
        logger.info ""
        logger.info "Success!".green, "🎉 Your new Bridgetown site was " \
                                      "generated in #{cli_path.cyan}."
        if options["skip-yarn"]
          logger.info "You can now #{"cd".cyan} #{cli_path.cyan} to get started."
          logger.info "You'll probably also want to #{"yarn install".cyan} " \
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

        logger.info "Yarn install skipped.".yellow if @skipped_yarn
      end
      # rubocop:enable Metrics/CyclomaticComplexity
      # rubocop:enable Metrics/PerceivedComplexity

      def bundle_install(path)
        unless Bridgetown.environment.test?
          require "bundler"
          Bridgetown.with_unbundled_env do
            inside(path) do
              run "bundle install", abort_on_failure: true
              run "bundle binstubs bridgetown-core"
              run "cp bin/bridgetown bin/bt"
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

      def yarn_install(path)
        unless Bridgetown.environment.test?
          inside(path) do
            run "yarn install", abort_on_failure: true
          end
        end
        @skipped_yarn = false
      rescue SystemExit
        say_status :alert, "Could not load yarn. yarn install skipped.", :red
      end
    end
  end
end

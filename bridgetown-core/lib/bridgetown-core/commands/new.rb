# frozen_string_literal: true

require "erb"

module Bridgetown
  module Commands
    class New < Command
      class << self
        DOCSURL = "https://bridgetownrb.com/docs"

        def init_with_program(prog)
          prog.command(:new) do |c|
            c.syntax "new PATH"
            c.description "Creates a new Bridgetown site scaffold in PATH"

            c.option "force", "--force", "Force creation even if PATH already exists"
            c.option "skip-bundle", "--skip-bundle", "Skip 'bundle install'"

            c.action do |args, options|
              Bridgetown::Commands::New.process(args, options)
            end
          end
        end

        def process(args, options = {})
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

          after_install(new_site_path, args.join(" "), options)
        end

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

            # Pull in latest Liquid from Shopify with new Render tag
            gem 'liquid', "> 4.0.3", github: "jaredcwhite/liquid"

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

        # After a new blog has been created, print a success notification and
        # then automatically execute bundle install from within the new blog dir
        # unless the user opts to generate a blank blog or skip 'bundle install'.
        # rubocop:disable Metrics/AbcSize #
        def after_install(path, cli_path, options = {})
          unless options["blank"] || options["skip-bundle"]
            begin
              require "bundler"
              bundle_install path
            rescue LoadError
              Bridgetown.logger.info "Could not load Bundler. Bundle install skipped."
            end
          end

          git_init path

          Bridgetown.logger.info "Success!".green, "🎉 Your new Bridgetown site was" \
                                  " generated in #{cli_path.cyan}."
          Bridgetown.logger.info "Execute cd #{cli_path.cyan} to get started."
          Bridgetown.logger.info "You'll probably also want to #{"yarn install".cyan}" \
                                  " to load in your frontend assets."
          Bridgetown.logger.info "Check out our online documentation for" \
                                  " next steps: #{DOCSURL.cyan}"
          Bridgetown.logger.info "Bundle install skipped." if options["skip-bundle"]
        end
        # rubocop:enable Metrics/AbcSize #

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
      end
    end
  end
end

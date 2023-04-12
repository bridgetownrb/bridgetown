# frozen_string_literal: true

module Bridgetown
  module Commands
    class Plugins < Thor
      include Thor::Actions
      include ConfigurationOverridable
      include GitHelpers

      Registrations.register do
        desc "plugins <command>", "List installed plugins or access plugin content"
        subcommand "plugins", Plugins
      end

      desc "list", "List information about installed plugins"
      option :verbose,
             type: :boolean,
             desc: "Print the source path of each plugin"
      def list
        config_options = configuration_with_overrides(options)
        config_options.run_initializers! context: :static
        site = Bridgetown::Site.new(config_options)
        site.reset
        Bridgetown::Hooks.trigger :site, :pre_read, site

        plugins_list = config_options.initializers.values.sort_by(&:name)

        pm = site.plugin_manager

        plugins_list += pm.class.registered_plugins.reject do |plugin|
          plugin.to_s.end_with? "site_builder.rb"
        end

        Bridgetown.logger.info("Registered Plugins:", plugins_list.length.to_s.yellow.bold)

        plugins_list.each do |plugin|
          plugin_desc = plugin.to_s
          next if plugin_desc.ends_with?("site_builder.rb") || plugin_desc == "init (Initializer)"

          if plugin.is_a?(Bridgetown::Configuration::Initializer)
            Bridgetown.logger.info("", plugin_desc)
            Bridgetown.logger.debug(
              "", "PATH: " + plugin.block.source_location[0]
            )
          elsif plugin.is_a?(Bundler::StubSpecification) || plugin.is_a?(Gem::Specification)
            Bridgetown.logger.info("", "#{plugin.name} (Rubygem)")
            Bridgetown.logger.debug(
              "", "PATH: " + plugin.full_gem_path
            )
          else
            Bridgetown.logger.info("", plugin_desc.sub(site.in_root_dir("/"), ""))
          end

          Bridgetown.logger.debug("")
        end

        unless site.config.source_manifests.empty?
          Bridgetown.logger.info("Source Manifests:", "----")
        end

        site.config.source_manifests.each do |manifest|
          Bridgetown.logger.info("Origin:", (manifest.origin || "n/a").to_s.green)
          Bridgetown.logger.info("Components:", (manifest.components || "n/a").to_s.cyan)
          Bridgetown.logger.info("Content:", (manifest.content || "n/a").to_s.cyan)
          Bridgetown.logger.info("Layouts:", (manifest.layouts || "n/a").to_s.cyan)

          Bridgetown.logger.info("", "----")
        end

        unless Bridgetown.autoload? :Builder
          builders = Bridgetown::Builder.descendants
          Bridgetown.logger.info("Builders:", builders.length.to_s.yellow.bold)

          builders.sort.each do |builder|
            name = plugin_name_for(builder)
            name_components = name.split("::")
            last_name = name_components.pop
            name_components.push last_name.magenta
            Bridgetown.logger.info("", name_components.join("::"))
            Bridgetown.logger.debug(
              "", "PATH: " + builder_path_for(builder)
            )
            Bridgetown.logger.debug("")
          end
          Bridgetown.logger.info("", "----")
        end

        Bridgetown.logger.info("Converters:", site.converters.length.to_s.yellow.bold)

        site.converters.each do |converter|
          name = plugin_name_for(converter)
          name_components = name.split("::")
          last_name = name_components.pop
          name_components.push last_name.magenta
          Bridgetown.logger.info("", name_components.join("::"))
          Bridgetown.logger.debug(
            "", "PATH: " + converter_path_for(converter)
          )
          Bridgetown.logger.debug("")
        end

        Bridgetown.logger.info("", "----")

        Bridgetown.logger.info("Generators:", site.generators.length.to_s.yellow.bold)

        site.generators.each do |generator|
          name = plugin_name_for(generator)
          name_components = name.split("::")
          last_name = name_components.pop
          name_components.push last_name.magenta
          Bridgetown.logger.info("", name_components.join("::"))
          Bridgetown.logger.debug(
            "", "PATH: " + generator_path_for(generator)
          )
          Bridgetown.logger.debug("")
        end
      end

      long_desc <<-DOC
        Open a directory (content, layouts, etc.) within the plugin origin. \n
        First run bridgetown plugins list to view source manifests currently
        set up on your site.\n
        Then look for the origin of the manifest and the folder you'd like to
        open.\n
        So for example, with an origin of SamplePlugin and a folder of
        Layouts, you'd run:\n
        bridgetown plugins cd SamplePlugin/Layouts
      DOC
      desc "cd <origin/dir>", "Open content folder within the plugin origin"

      # This is super useful if you want to copy files out of plugins to override.
      #
      # Example:
      #   bridgetown plugins cd AwesomePlugin/layouts
      #   cp -r * $BRIDGETOWN_SITE/src/_layouts
      #
      # Now all the plugin's layouts will be in the site repo directly.
      #
      def cd(arg)
        config_options = configuration_with_overrides(options)
        config_options.run_initializers! context: :static

        directive = arg.split("/")
        unless directive[1]
          Bridgetown.logger.warn("Oops!", "Your command needs to be in the <origin/dir> format")
          return
        end

        manifest = config_options.source_manifests.find do |source_manifest|
          source_manifest.origin.to_s == directive[0]
        end

        if manifest.respond_to?(directive[1].downcase)
          dir = manifest.send(directive[1].downcase)
          Bridgetown.logger.info("Opening the #{dir.green} folder for" \
                                 " #{manifest.origin.to_s.cyan}…")
          Bridgetown.logger.info("Type #{"exit".yellow} when you're done to" \
                                 " return to your site root.")
          puts

          # rubocop: disable Style/RedundantCondition
          Dir.chdir dir do
            ENV["BRIDGETOWN_SITE"] = config_options.root_dir
            if ENV["SHELL"]
              system(ENV["SHELL"])
            else
              system("/bin/sh")
            end
          end
          # rubocop: enable Style/RedundantCondition

          puts
          Bridgetown.logger.info("Done!", "You're back in #{Dir.pwd.green}")
        else
          Bridgetown.logger.warn("Oops!", "I wasn't able to find the" \
                                          " #{directive[1]} folder for #{directive[0]}")
        end
      end

      desc "new NAME", "Create a new plugin NAME (snake_case_name_preferred)"
      def new(name)
        folder_name = name.underscore
        module_name = folder_name.camelize

        run "git clone https://github.com/bridgetownrb/bridgetown-sample-plugin #{name}"
        new_gemspec = "#{folder_name}.gemspec"

        inside name do # rubocop:todo Metrics/BlockLength
          destroy_existing_repo
          initialize_new_repo

          FileUtils.mv "sample_plugin.gemspec", new_gemspec
          gsub_file new_gemspec, "https://github.com/bridgetownrb/bridgetown-sample-plugin", "https://github.com/username/#{name}"
          gsub_file new_gemspec, "bridgetown-sample-plugin", name
          gsub_file new_gemspec, "sample_plugin", folder_name
          gsub_file new_gemspec, "SamplePlugin", module_name

          gsub_file "package.json", "https://github.com/bridgetownrb/bridgetown-sample-plugin", "https://github.com/username/#{name}"
          gsub_file "package.json", "bridgetown-sample-plugin", name
          gsub_file "package.json", "sample_plugin", folder_name

          FileUtils.mv "lib/sample_plugin.rb", "lib/#{folder_name}.rb"
          gsub_file "lib/#{folder_name}.rb", "sample_plugin", folder_name
          gsub_file "lib/#{folder_name}.rb", "SamplePlugin", module_name

          FileUtils.mv "lib/sample_plugin", "lib/#{folder_name}"
          gsub_file "lib/#{folder_name}/builder.rb", "SamplePlugin", module_name
          gsub_file "lib/#{folder_name}/builder.rb", "sample_plugin", folder_name
          gsub_file "lib/#{folder_name}/version.rb", "SamplePlugin", module_name

          FileUtils.mv "test/test_sample_plugin.rb", "test/test_#{folder_name}.rb"
          gsub_file "test/test_#{folder_name}.rb", "SamplePlugin", module_name
          gsub_file "test/test_#{folder_name}.rb", "sample plugin", module_name
          gsub_file "test/helper.rb", "sample_plugin", folder_name
          gsub_file "test/fixtures/src/index.html", "sample_plugin", folder_name
          gsub_file "test/fixtures/config/initializers.rb", "sample_plugin", folder_name

          FileUtils.mv "components/sample_plugin", "components/#{folder_name}"
          FileUtils.mv "content/sample_plugin", "content/#{folder_name}"
          FileUtils.mv "layouts/sample_plugin", "layouts/#{folder_name}"

          gsub_file "layouts/#{folder_name}/layout.html", "sample_plugin", folder_name
          gsub_file "content/#{folder_name}/example_page.md", "sample_plugin", folder_name
          gsub_file "components/#{folder_name}/layout_help.liquid", "sample_plugin", folder_name

          gsub_file "components/#{folder_name}/plugin_component.rb", "SamplePlugin", module_name

          gsub_file "frontend/javascript/index.js", "sample_plugin", folder_name
          gsub_file "frontend/javascript/index.js", "SamplePlugin", module_name
          gsub_file "frontend/styles/index.css", "sample_plugin", folder_name
        end
        say ""
        say_status "Done!", "Have fun writing your new #{name} plugin :)"
        say_status "Remember:", "Don't forget to rename the SamplePlugin" \
                                " code identifiers and paths to your own" \
                                " identifier, as well as update your README" \
                                " and CHANGELOG files as necessary."
      end

      protected

      def plugin_name_for(plugin)
        klass = plugin.is_a?(Class) ? plugin : plugin.class
        klass.respond_to?(:custom_name) ? klass.custom_name : klass.name
      end

      def builder_path_for(plugin)
        klass = plugin.is_a?(Class) ? plugin : plugin.class
        klass.instance_method(:build).source_location[0]
      end

      def converter_path_for(plugin)
        klass = plugin.is_a?(Class) ? plugin : plugin.class
        klass.instance_method(:convert).source_location[0]
      end

      def generator_path_for(plugin)
        klass = plugin.is_a?(Class) ? plugin : plugin.class
        klass.instance_method(:generate).source_location[0]
      end
    end
  end
end

# frozen_string_literal: true

module Bridgetown
  module Commands
    class Plugins < Thor
      include Thor::Actions
      include ConfigurationOverridable

      Registrations.register do
        desc "plugins <command>", "List installed plugins or access plugin content"
        subcommand "plugins", Plugins
      end

      desc "list", "List information about installed plugins"
      def list
        site = Bridgetown::Site.new(configuration_with_overrides(options))
        site.reset
        Bridgetown::Hooks.trigger :site, :pre_read, site

        pm = site.plugin_manager

        plugins_list = pm.class.registered_plugins.reject do |plugin|
          plugin.to_s.end_with? "site_builder.rb"
        end

        Bridgetown.logger.info("Registered Plugins:", plugins_list.length.to_s.yellow.bold)

        plugins_list.each do |plugin|
          unless plugin.to_s.end_with? "site_builder.rb"
            Bridgetown.logger.info("", plugin.to_s.sub(site.in_root_dir("/"), ""))
          end
        end

        Bridgetown.logger.info("Source Manifests:", "---") unless pm.class.source_manifests.empty?

        pm.class.source_manifests.each do |manifest|
          Bridgetown.logger.info("Origin:", (manifest.origin || "n/a").to_s.green)
          Bridgetown.logger.info("Components:", (manifest.components || "n/a").to_s.cyan)
          Bridgetown.logger.info("Content:", (manifest.content || "n/a").to_s.cyan)
          Bridgetown.logger.info("Layouts:", (manifest.layouts || "n/a").to_s.cyan)

          Bridgetown.logger.info("", "---")
        end

        unless Bridgetown.autoload? :Builder
          builders = Bridgetown::Builder.descendants
          Bridgetown.logger.info("Builders:", builders.length.to_s.yellow.bold)

          builders.each do |builder|
            name = builder.respond_to?(:custom_name) ? builder.custom_name : builder.name
            name_components = name.split("::")
            last_name = name_components.pop
            name_components.push last_name.magenta
            Bridgetown.logger.info("", name_components.join("::"))
          end
        end

        Bridgetown.logger.info("Converters:", site.converters.length.to_s.yellow.bold)

        site.converters.each do |converter|
          name = plugin_name_for(converter)
          name_components = name.split("::")
          last_name = name_components.pop
          name_components.push last_name.magenta
          Bridgetown.logger.info("", name_components.join("::"))
        end

        Bridgetown.logger.info("Generators:", site.generators.length.to_s.yellow.bold)

        site.generators.each do |generator|
          name = plugin_name_for(generator)
          name_components = name.split("::")
          last_name = name_components.pop
          name_components.push last_name.magenta
          Bridgetown.logger.info("", name_components.join("::"))
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
      desc "cd <origin/dir>", "Open folder (content, layouts, etc.) within the plugin origin"

      # This is super useful if you want to copy files out of plugins to override.
      #
      # Example:
      #   bridgetown plugins cd AwesomePlugin/layouts
      #   cp -r * $BRIDGETOWN_SITE/src/_layouts
      #
      # Now all the plugin's layouts will be in the site repo directly.
      #
      def cd(arg)
        site = Bridgetown::Site.new(configuration_with_overrides(options))

        pm = site.plugin_manager

        directive = arg.split("/")
        unless directive[1]
          Bridgetown.logger.warn("Oops!", "Your command needs to be in the <origin/dir> format")
          return
        end

        manifest = pm.class.source_manifests.find do |source_manifest|
          source_manifest.origin.to_s == directive[0]
        end

        if manifest&.respond_to?(directive[1].downcase)
          dir = manifest.send(directive[1].downcase)
          Bridgetown.logger.info("Opening the #{dir.green} folder for" \
                                  " #{manifest.origin.to_s.cyan}…")
          Bridgetown.logger.info("Type #{"exit".yellow} when you're done to" \
                                  " return to your site root.")
          puts

          Dir.chdir dir do
            ENV["BRIDGETOWN_SITE"] = site.root_dir
            if ENV["SHELL"]
              system(ENV["SHELL"])
            else
              system("/bin/sh")
            end
          end

          puts
          Bridgetown.logger.info("Done!", "You're back in #{Dir.pwd.green}")
        else
          Bridgetown.logger.warn("Oops!", "I wasn't able to find the" \
                                  " #{directive[1]} folder for #{directive[0]}")
        end
      end

      desc "new NAME", "Create a new plugin NAME (please-use-dashes) by" \
                       " cloning the sample plugin repo"
      # rubocop:disable Layout/LineLength
      def new(plugin_name)
        folder_name = plugin_name.underscore
        name = folder_name.dasherize
        module_name = folder_name.camelize

        run "git clone https://github.com/bridgetownrb/bridgetown-sample-plugin #{name}"
        new_gemspec = "#{name}.gemspec"

        inside name do # rubocop:todo Metrics/BlockLength
          run "rm -rf .git"
          run "git init"

          run "mv bridgetown-sample-plugin.gemspec #{new_gemspec}"
          gsub_file new_gemspec, "https://github.com/bridgetownrb/bridgetown-sample-plugin", "https://github.com/username/#{name}"
          gsub_file new_gemspec, "bridgetown-sample-plugin", name
          gsub_file new_gemspec, "sample-plugin", name
          gsub_file new_gemspec, "SamplePlugin", module_name

          gsub_file "package.json", "https://github.com/bridgetownrb/bridgetown-sample-plugin", "https://github.com/username/#{name}"
          gsub_file "package.json", "bridgetown-sample-plugin", name

          run "mv lib/sample-plugin.rb lib/#{name}.rb"
          gsub_file "lib/#{name}.rb", "sample-plugin", name
          gsub_file "lib/#{name}.rb", "SamplePlugin", module_name

          run "mv lib/sample-plugin lib/#{name}"
          gsub_file "lib/#{name}/builder.rb", "SamplePlugin", module_name
          gsub_file "lib/#{name}/version.rb", "SamplePlugin", module_name

          run "mv spec/sample-plugin_spec.rb spec/#{name}_spec.rb"
          gsub_file "spec/#{name}_spec.rb", "SamplePlugin", module_name
          gsub_file "spec/spec_helper.rb", "sample-plugin", name

          run "mv components/sample_plugin components/#{folder_name}"
          run "mv content/sample_plugin content/#{folder_name}"
          run "mv layouts/sample_plugin layouts/#{folder_name}"

          gsub_file "layouts/#{folder_name}/layout.html", "sample_plugin", folder_name
          gsub_file "content/#{folder_name}/example_page.md", "sample_plugin", folder_name
          gsub_file "components/#{folder_name}/layout_help.liquid", "sample_plugin", folder_name

          gsub_file "frontend/javascript/index.js", "bridgetown-sample-plugin", name
          gsub_file "frontend/javascript/index.js", "SamplePlugin", module_name
        end
        say ""
        say_status "Done!", "Have fun writing your new #{name} plugin :)"
        say_status "Remember:", "Don't forget to rename the SamplePlugin" \
                               " code identifiers and paths to your own" \
                               " indentifer, as well as update your README " \
                               " and CHANGELOG files as necessary."
      end
      # rubocop:enable Layout/LineLength

      protected

      def plugin_name_for(plugin)
        if plugin.class.respond_to?(:custom_name)
          plugin.class.custom_name
        else
          plugin.class.name
        end
      end
    end
  end
end

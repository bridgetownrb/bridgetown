# frozen_string_literal: true

module Bridgetown
  module Commands
    class Plugins < Command
      class << self
        def init_with_program(prog)
          plugins_cmd = prog.command(:plugins) do |c|
            c.syntax "plugins <subcommand>"
            c.description "List installed plugins or access plugin content"

            c.option "config", "--config CONFIG_FILE[,CONFIG_FILE2,...]", Array,
                     "Custom configuration file"

            c.action do
              output_supercommand_syntax(c)
            end
          end

          plugins_cmd.command(:list) do |subcmd|
            subcmd.syntax "list"
            subcmd.description "List information about installed plugins"

            subcmd.action do |_, options|
              list(options)
            end
          end

          plugins_cmd.command(:cd) do |subcmd|
            subcmd.syntax "cd <origin/dir>"
            subcmd.description "Open directory (content, layouts, etc.) within the plugin origin"

            subcmd.action do |args, options|
              if args.empty?
                puts subcmd.to_s
              else
                cd(args, options)
              end
            end
          end
        end

        def output_supercommand_syntax(supercmd)
          puts supercmd.to_s
        end

        def list(options)
          site = Bridgetown::Site.new(configuration_from_options(options))
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

        # This is super useful if you want to copy files out of plugins to override.
        #
        # Example:
        #   bridgetown plugins cd AwesomePlugin/layouts
        #   cp -r * $BRIDGETOWN_SITE/src/_layouts
        #
        # Now all the plugin's layouts will be in the site repo directly.
        #
        def cd(args, options)
          site = Bridgetown::Site.new(configuration_from_options(options))

          pm = site.plugin_manager

          directive = args[0].split("/")
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
end

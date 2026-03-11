module Bridgetown
  module Commands
    class Floob < Bridgetown::Command
      self.description = "Florb the floob"

      def call
        puts "YES!"
      end
    end

    register_command :floob, Floob

    class ImportPluginsFromGitHub < Bridgetown::Command
      include Bridgetown::Commands::Automations
      include Bridgetown::Commands::ConfigurationOverridable

      self.description = "Import plugins from the GitHub cache"

      def call
        config = configuration_with_overrides(options)
        config.run_initializers! context: :static
        site = Bridgetown::Site.new(config)

        plugins = ::Builders::Versions.cache["plugins"]
        plugins.each do |plugin_json|
          plugin_json = HashWithDotAccess::Hash.new(plugin_json)
          origin = Bridgetown::Model::RepoOrigin.new_with_collection_path(:plugins, "_plugins/#{plugin_json.owner.login}/#{plugin_json.name}.md")
          unless origin.exists?
            model = Bridgetown::Model::Base.new(
              title: plugin_json.name,
              repo_url: plugin_json.html_url,
              author: {
                handle: plugin_json.owner.login,
                avatar_url: plugin_json.owner.avatar_url,
                profile_url: plugin_json.owner.html_url
              }
            )
            model.content = plugin_json.description
            model.origin = origin
            model.save

            puts "Done! Saved in: src/#{origin.relative_path}"
          end
        end
      end
    end

    register_command :import_plugins, ImportPluginsFromGitHub
  end
end

module MyPlugin
  module Commands
    class River < Thor
      include Bridgetown::Commands::ConfigurationOverridable

      include Thor::Actions
      include Bridgetown::Commands::Actions

      Bridgetown::Commands::Registrations.register do
        desc "river <command>", "Take me to the river"
        subcommand "river", River
      end

      desc "bank", "Walk along the river bank"
      option :lolz, aliases: "-l", required: true, type: :numeric
      option :derp, type: :array
      def bank
        puts options[:derp].inspect
        puts "Out for a stroll... #{options[:lolz].class} #{options[:lolz]}"
      end

      desc "flow", "Old man river, he just keeps on rolling along"
      option :destination, desc: "Override configuration file destination", required: true
      def flow
        config = configuration_with_overrides(options)
        destination = config["destination"]

        say_status :river, "Go with the flow! :) to: #{destination}"
      end
    end
  end
end

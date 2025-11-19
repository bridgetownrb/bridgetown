class Floob < Samovar::Command
  Bridgetown::Commands2::Registrations.register Floob, "floob"

  self.description = "Florb the floob"

  def call
    puts "YES!"
  end
end

module MyPlugin
  module Commands
    class River < Thor
      include Bridgetown::Commands2::ConfigurationOverridable

      include Thor::Actions
      include Bridgetown::Commands::Actions

      Bridgetown::Commands2::Registrations.register do
        desc "river <command>", "Take me to the river"
        subcommand "river", River
      end

      desc "bank", "Walk along the river bank"
      def bank
        puts "Out for a stroll..."
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

# frozen_string_literal: true

module Bridgetown
  module ConsoleMethods
    def reload!
      Bridgetown.logger.info "Reloading site..."

      site = Bridgetown::Current.site

      I18n.reload! # make sure any locale files get read again
      site.loaders_manager.reload_loaders(site)

      ConsoleMethods.site_reset(site)
    end

    def self.site_reset(site)
      site.reset
      Bridgetown.logger.info "Reading files..."
      site.read
      Bridgetown.logger.info "", "done!"
      Bridgetown.logger.info "Running generators..."
      site.generate
      Bridgetown.logger.info "", "done!"
    end
  end

  module Commands
    class Console < Bridgetown::Command
      include ConfigurationOverridable

      self.description = "Invoke an IRB console with the site loaded"

      options do
        ConfigurationOverridable.include_options(self)
        option "--blank", "Skip reading content and running generators before opening console"
        option "--bypass-ap", "Don't load AmazingPrint when IRB opens"
        option "--config <FILE1,FILE2>", "Custom configuration file(s)" do |value|
          value.split(%r{\s*,\s*})
        end
        option "-s/--server-config", "Load server configurations"
        option "-V/--verbose", "Print verbose output"
      end

      def call # rubocop:disable Metrics
        require "irb"
        new_history_behavior = false
        begin
          require "irb/ext/save-history"
        rescue LoadError
          # Code path for Ruby 3.3+
          new_history_behavior = true
        end
        require "amazing_print" unless options[:bypass_ap]

        Bridgetown.logger.adjust_verbosity(**options)

        Bridgetown.logger.info "Starting:", "Bridgetown v#{Bridgetown::VERSION.magenta} " \
                                            "(codename \"#{Bridgetown::CODE_NAME.yellow}\") " \
                                            "console…"
        Bridgetown.logger.info "Environment:", Bridgetown.environment.cyan

        config_options = configuration_with_overrides(options)

        if options[:server_config]
          require "bridgetown-core/rack/boot"
          Bridgetown::Rack.boot
          begin
            require "rack/test"
            IRB::ExtendCommandBundle.include ::Rack::Test::Methods
            ConsoleMethods.module_eval do
              def app = Roda.subclasses[0].app
            end
            @rack_test_installed = true
          rescue LoadError # rubocop:disable Lint/SuppressedException
          end
        else
          config_options.run_initializers! context: :console
        end
        site = Bridgetown::Site.new(config_options)

        ConsoleMethods.site_reset(site) unless options[:blank]

        IRB::ExtendCommandBundle.include ConsoleMethods
        IRB.setup(nil)
        workspace = IRB::WorkSpace.new
        workspace.main.define_singleton_method(:site) { Bridgetown::Current.site }
        workspace.main.define_singleton_method(:collections) { site.collections }
        workspace.main.define_singleton_method(:helpers) do
          Bridgetown::TemplateView::Helpers.new
        end
        irb = IRB::Irb.new(workspace)
        IRB.conf[:IRB_RC]&.call(irb.context)
        IRB.conf[:MAIN_CONTEXT] = irb.context
        irb.context.io.load_history if new_history_behavior
        Bridgetown.logger.info "Console:", "Your site is now available as #{"site".cyan}."
        if options[:server_config]
          Bridgetown.logger.info "",
                                 "Your Roda app is available as #{Roda.subclasses[0].to_s.cyan}."
          if @rack_test_installed
            Bridgetown.logger.info "", "You can use #{"Rack::Test".magenta} methods like #{"get".cyan}, #{"post".cyan}, and #{"last_response".cyan} to inspect" # rubocop:disable Layout/LineLength
            Bridgetown.logger.info "", "  static & dynamic routes in your application."
          end
        end
        Bridgetown.logger.info "",
                               "You can also access #{"collections".cyan} or perform a " \
                               "#{"reload!".cyan}"

        trap("SIGINT") do
          irb.signal_handle
        end

        begin
          catch(:IRB_EXIT) do
            unless options[:bypass_ap]
              AmazingPrint.defaults = {
                indent: 2,
              }
              AmazingPrint.irb!
            end
            irb.eval_input
          end
        ensure
          IRB.conf[:AT_EXIT].each(&:call)
          irb.context.io.save_history if new_history_behavior
        end
      end
    end

    register_command :console, Console
  end
end

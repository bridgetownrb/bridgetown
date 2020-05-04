# frozen_string_literal: true

require "irb"

module Bridgetown
  module Commands
    class Console < Command
      class << self
        def init_with_program(prog)
          prog.command(:console) do |c|
            c.syntax "console"
            c.description "Invoke an IRB console with the site loaded"
            c.alias :c

            c.option "config", "--config CONFIG_FILE[,CONFIG_FILE2,...]", Array,
                     "Custom configuration file"

            c.action do |_, options|
              Bridgetown::Commands::Console.process(options)
            end
          end
        end

        # TODO: is there a way to add a unit test for this command?
        # rubocop:disable Style/GlobalVars, Metrics/AbcSize, Metrics/MethodLength
        def process(options)
          Bridgetown.logger.info "Starting:", "Bridgetown v#{Bridgetown::VERSION.magenta}" \
                                      " (codename \"#{Bridgetown::CODE_NAME.yellow}\")" \
                                      " console…"
          Bridgetown.logger.info "Environment:", Bridgetown.environment.cyan
          site = Bridgetown::Site.new(configuration_from_options(options))
          site.reset
          site.read
          site.generate

          $BRIDGETOWN_SITE = site
          IRB.setup(nil)
          workspace = IRB::WorkSpace.new
          irb = IRB::Irb.new(workspace)
          IRB.conf[:MAIN_CONTEXT] = irb.context
          eval("site = $BRIDGETOWN_SITE", workspace.binding, __FILE__, __LINE__)
          Bridgetown.logger.info "Console:", "Now loaded as " + "site".cyan + " variable."

          trap("SIGINT") do
            irb.signal_handle
          end

          begin
            catch(:IRB_EXIT) do
              irb.eval_input
            end
          end
        end
        # rubocop:enable Style/GlobalVars, Metrics/AbcSize, Metrics/MethodLength
      end
    end
  end
end

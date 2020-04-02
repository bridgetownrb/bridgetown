# frozen_string_literal: true

require "erb"

module Bridgetown
  module Commands
    class NewTheme < Bridgetown::Command
      class << self
        def init_with_program(prog)
          prog.command(:"new-theme") do |c|
            c.syntax "new-theme NAME"
            c.description "Creates a new Bridgetown theme scaffold"
            c.option "code_of_conduct", \
                     "-c", "--code-of-conduct", \
                     "Include a Code of Conduct. (defaults to false)"

            c.action do |args, opts|
              Bridgetown::Commands::NewTheme.process(args, opts)
            end
          end
        end

        # rubocop:disable Metrics/AbcSize
        def process(args, opts)
          if !args || args.empty?
            raise Bridgetown::Errors::InvalidThemeName, "You must specify a theme name."
          end

          new_theme_name = args.join("_")
          theme = Bridgetown::ThemeBuilder.new(new_theme_name, opts)
          Bridgetown.logger.abort_with "Conflict:", "#{theme.path} already exists." if theme.path.exist?

          theme.create!
          Bridgetown.logger.info "Your new Bridgetown theme, #{theme.name.cyan}," \
                             " is ready for you in #{theme.path.to_s.cyan}!"
          Bridgetown.logger.info "For help getting started, read #{theme.path}/README.md."
        end
        # rubocop:enable Metrics/AbcSize
      end
    end
  end
end

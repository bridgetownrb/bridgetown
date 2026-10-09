# frozen_string_literal: true

class Bridgetown::Site
  module Builder
    def build # rubocop:disable Metrics/AbcSize
      Bridgetown.logger.info "Environment:", Bridgetown.environment.cyan
      Bridgetown.logger.info "Source:", source
      Bridgetown.logger.info "Destination:", destination
      Bridgetown.logger.info ""
      Bridgetown.logger.info "Starting:", "Bridgetown v#{Bridgetown::VERSION.magenta} " \
                                          "(codename \"#{Bridgetown::CODE_NAME.yellow}\")"
      Bridgetown.logger.info ""

      t = Time.now
      if config["unpublished"]
        Bridgetown.logger.info "Unpublished mode:",
                               "enabled. Processing documents marked unpublished"
      end
      Bridgetown.logger.info "Generating…"
      process
      Bridgetown.logger.info "Done! 🎉", "#{"Completed".bold.green} in less than " \
                                        "#{(Time.now - t).ceil(2)} seconds."
    end
  end
end

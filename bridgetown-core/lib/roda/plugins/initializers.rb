# frozen_string_literal: true

class Roda
  module RodaPlugins
    module Initializers
      def self.load_dependencies(app)
        Bridgetown::Current.preloaded_configuration.initialize_roda_app(app)
      end

      def self.configure(app, _opts = {})
        app.opts[:bridgetown_preloaded_config] = Bridgetown::Current.preloaded_configuration
      end
    end

    register_plugin :initializers, Initializers
  end
end

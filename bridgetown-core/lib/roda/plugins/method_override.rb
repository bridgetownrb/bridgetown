# frozen_string_literal: true

class Roda
  module RodaPlugins
    # This is a simplified Roda plugin version of the Rack middleware:
    # https://github.com/rack/rack/blob/v2.2.2/lib/rack/method_override.rb
    module MethodOverride
      def self.configure(app, opts = {})
        app.opts[:method_override_param] = opts[:method_override_param] || "_method"
      end

      module RequestMethods
        HTTP_METHODS = %w(GET HEAD PUT POST DELETE OPTIONS PATCH LINK UNLINK).freeze
        HTTP_METHOD_OVERRIDE_HEADER = "HTTP_X_HTTP_METHOD_OVERRIDE"
        ALLOWED_METHODS = %w(POST).freeze

        def initialize(scope, env)
          super
          return unless _allowed_methods.include?(env[Rack::REQUEST_METHOD])

          method = _method_override(env)
          return unless HTTP_METHODS.include?(method)

          env[Rack::RACK_METHODOVERRIDE_ORIGINAL_METHOD] = env[Rack::REQUEST_METHOD]
          env[Rack::REQUEST_METHOD] = method
        end

        private

        def _method_override(env)
          method = _method_override_param ||
            env[HTTP_METHOD_OVERRIDE_HEADER]
          method.to_s.upcase
        end

        def _allowed_methods
          ALLOWED_METHODS
        end

        def _method_override_param
          params[scope.class.opts[:method_override_param]]
        end
      end
    end

    register_plugin :method_override, MethodOverride
  end
end

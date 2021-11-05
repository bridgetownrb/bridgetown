# frozen_string_literal: true

module Bridgetown
  module Rack
    class Routes
      class << self
        attr_accessor :tracked_subclasses, :router_block

        def inherited(base)
          Bridgetown::Rack::Routes.track_subclass base
          super
        end

        def track_subclass(klass)
          Bridgetown::Rack::Routes.tracked_subclasses ||= {}
          Bridgetown::Rack::Routes.tracked_subclasses[klass.name] = klass
        end

        def reload_subclasses
          Bridgetown::Rack::Routes.tracked_subclasses&.each_key do |klassname|
            Kernel.const_get(klassname)
          rescue NameError
            Bridgetown::Rack::Routes.tracked_subclasses.delete klassname
          end
        end

        def route(&block)
          self.router_block = block
        end

        def merge(roda_app)
          return unless router_block

          new(roda_app).handle_routes
        end

        def start!(roda_app)
          if Bridgetown.env.development? &&
              !Bridgetown::Current.preloaded_configuration.skip_live_reload
            setup_live_reload roda_app.request
          end

          Bridgetown::Rack::Routes.tracked_subclasses&.each_value do |klass|
            klass.merge roda_app
          end

          if defined?(Bridgetown::Routes::RodaRouter)
            Bridgetown::Routes::RodaRouter.start!(roda_app)
          end

          nil
        end

        def setup_live_reload(request)
          request.get "_bridgetown/live_reload" do
            {
              last_mod: File.stat(
                File.join(Bridgetown::Current.preloaded_configuration.destination, "index.html")
              ).mtime.to_i,
            }
          rescue StandardError => e
            { last_mod: 0, error: e.message }
          end
        end
      end

      def initialize(roda_app)
        @_roda_app = roda_app
      end

      def handle_routes
        instance_exec(@_roda_app.request, &self.class.router_block)
      end

      def method_missing(method_name, *args, **kwargs, &block)
        if @_roda_app.respond_to?(method_name.to_sym)
          @_roda_app.send method_name.to_sym, *args, **kwargs, &block
        else
          super
        end
      end

      def respond_to_missing?(method_name, include_private = false)
        @_roda_app.respond_to?(method_name.to_sym, include_private) || super
      end
    end
  end
end

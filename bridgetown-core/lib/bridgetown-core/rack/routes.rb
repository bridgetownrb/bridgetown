# frozen_string_literal: true

module Bridgetown
  module Rack
    @interrupted = false

    class << self
      attr_accessor :interrupted
    end

    class Routes
      PRIORITIES = {
        highest: "010",
        high: "020",
        normal: "030",
        low: "040",
        lowest: "050",
      }.freeze

      # Get or set the priority of this plugin. When called without an
      # argument it returns the priority. When an argument is given, it will
      # set the priority.
      #
      # priority - The Symbol priority (default: nil). Valid options are:
      #            :lowest, :low, :normal, :high, :highest
      #
      # Returns the Symbol priority.
      def self.priority(priority = nil)
        @priority ||= nil
        @priority = priority if priority && PRIORITIES.key?(priority)
        @priority || :normal
      end

      # Spaceship is priority [higher -> lower]
      #
      # other - The class to be compared.
      #
      # Returns -1, 0, 1.
      def self.<=>(other)
        "#{PRIORITIES[priority]}#{self}" <=> "#{PRIORITIES[other.priority]}#{other}"
      end

      # Spaceship is priority [higher -> lower]
      #
      # other - The class to be compared.
      #
      # Returns -1, 0, 1.
      def <=>(other)
        self.class <=> other.class
      end

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

        def sorted_subclasses
          Bridgetown::Rack::Routes.tracked_subclasses&.values&.sort
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
          if Bridgetown::Current.preloaded_configuration.base_path == "/"
            load_all_routes roda_app
            return
          end

          # Support custom base_path configurations
          roda_app.request.on(
            Bridgetown::Current.preloaded_configuration.base_path.delete_prefix("/")
          ) do
            load_all_routes roda_app
          end

          nil
        end

        def load_all_routes(roda_app)
          roda_app.request.public

          if Bridgetown.env.development? &&
              !Bridgetown::Current.preloaded_configuration.skip_live_reload
            setup_live_reload roda_app
          end

          Bridgetown::Rack::Routes.sorted_subclasses&.each do |klass|
            klass.merge roda_app
          end

          return unless defined?(Bridgetown::Routes::RodaRouter)

          Bridgetown::Routes::RodaRouter.start!(roda_app)
        end

        def setup_live_reload(app) # rubocop:disable Metrics/AbcSize
          sleep_interval = 0.2
          file_to_check = File.join(app.class.opts[:bridgetown_preloaded_config].destination,
                                    "index.html")

          app.request.get "_bridgetown/live_reload" do
            app.response["Content-Type"] = "text/event-stream"

            @_mod = File.exist?(file_to_check) ? File.stat(file_to_check).mtime.to_i : 0
            app.stream async: true do |out|
              # 5 second intervals so Puma's threads aren't all exausted
              (5 / sleep_interval).to_i.times do
                break if Bridgetown::Rack.interrupted

                new_mod = File.exist?(file_to_check) ? File.stat(file_to_check).mtime.to_i : 0
                if @_mod < new_mod
                  out << "data: reloaded!\n\n"
                  break
                else
                  out << "data: #{new_mod}\n\n"
                end

                sleep sleep_interval
              end
            end
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

if Bridgetown.env.development? &&
    !Bridgetown::Current.preloaded_configuration.skip_live_reload
  Puma::Launcher.class_eval do
    alias_method :_old_stop, :stop
    def stop
      Bridgetown::Rack.interrupted = true

      _old_stop
    end
  end
end

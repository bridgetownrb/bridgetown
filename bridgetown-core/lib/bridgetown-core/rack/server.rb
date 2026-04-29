# frozen_string_literal: true

module Bridgetown
  module Rack
    class Server
      attr_reader :name

      def initialize(config, port: nil, bind: nil)
        @name = nil
        @port = port
        @bind = bind

        # Evaluate the configuration first
        if File.exist?(config)
          config = File.read(config)
          instance_eval(config)
        end

        # If no server is found, try and automatically detect one
        if @name.nil? && detected_server
          @name = detected_server.to_s.downcase
          include_default_environment
        end

        # Raise error if no server can be found
        if @name.nil?
          raise "No suitable Rack server was found."
        end
      end

      # We `include` the server's environment module into the class
      # during initialization. Hence, we create a duplicate before
      # instantiating the class, so every time the server is created,
      # it's a clean slate.
      def self.new(config = "config/web_server.rb", port: nil, bind: nil)
        return super unless self == Bridgetown::Rack::Server

        dup.new(config, port: port, bind: bind)
      end

      private

      def server(name, &)
        raise "Only a single server can be configured" if @name

        instance_eval(&) if block_given?
        @name = name

        raise "#{@name.capitalize} server was not found in your bundle" \
          unless available?(@name)

        include_default_environment
      end

      def include_default_environment
        server_environment = "Bridgetown::Rack::Environment::#{@name.capitalize}"
        return unless Object.const_defined?(server_environment)

        self.class.include Object.const_get(server_environment)
      end

      def supported_servers
        @supported_servers ||= Bridgetown::Rack::Environment.constants
      end

      def detected_server
        @detected_server ||=
          supported_servers.filter { available?(_1) }.first
      end

      def available?(server)
        Gem.loaded_specs.key?(server.to_s.downcase)
      end

      def method_missing(name, *args, &block)
        return super unless respond_to_missing?

        if block
          self.class.define_method(name, &block)
        else
          self.class.define_method(name) { args.first }
        end
      end

      def respond_to_missing?
        @name.nil?
      end
    end
  end
end

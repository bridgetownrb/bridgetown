# frozen_string_literal: true

module Bridgetown
  module Routines
    class Server
      def initialize(site:, port: nil, bind: nil)
        @site = site
        @port = port
        @bind = bind
      end

      def execute(instance) # rubocop:disable Metrics/AbcSize
        Bridgetown.logger.set_prefix("Server", color: :yellow)

        server = Bridgetown::Rack::Server.new(port: @port, bind: @bind)

        Bridgetown.logger.info ""
        Bridgetown.logger.info "", "Starting Bridgetown server ...".white

        if server.respond_to?(:bind) && server.respond_to?(:port)
          uri = URI("#{server.bind}:#{server.port}")
          uri.scheme = uri.scheme.gsub("tcp", "http").gsub("ssl", "https")

          Bridgetown.logger.info "", "Serving at: ".white
          Bridgetown.logger.info "", uri.to_s.cyan
          Bridgetown.logger.info "", "#{uri.scheme}://#{external_ip}:#{server.port}"
        end

        Bridgetown.logger.info ""

        instance.exec("bundle", "exec", *server.command, ready: true)
      end

      def name  = "Bridgetown Server"
      def key   = :server

      private

      def external_ip
        require "socket"
        @external_ip ||= Socket.ip_address_list.find do |ai|
          ai.ipv4? && !ai.ipv4_loopback?
        end&.ip_address
      end
    end
  end
end

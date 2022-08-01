# frozen_string_literal: true

module Bridgetown
  module Commands
    class Serve < Thor::Group
      extend BuildOptions
      extend Summarizable
      include ConfigurationOverridable

      Registrations.register do
        register(Serve, "serve", "serve", Serve.summary)
      end

      class_option :host, aliases: "-H", desc: "Host to bind to"
      class_option :port, aliases: "-P", desc: "Port to listen on"
      class_option :detach,
                   aliases: "-B",
                   type: :boolean,
                   desc: "Run the server in the background"
      class_option :ssl_cert, desc: "X.509 (SSL) certificate."
      class_option :ssl_key, desc: "X.509 (SSL) Private Key."
      class_option :show_dir_listing,
                   type: :boolean,
                   desc: "Show a directory listing instead of loading your index file."
      class_option :skip_initial_build,
                   type: :boolean,
                   desc: "Skips the initial site build which occurs before the server is started."
      class_option :watch,
                   type: :boolean,
                   aliases: "-w",
                   default: true,
                   desc: "Watch for changes and rebuild"

      def self.banner
        "bridgetown serve [options]"
      end
      summary "DEPRECATED (Serve your site locally using WEBrick)"

      DIRECTORY_INDEX = %w(
        index.htm
        index.html
        index.rhtml
        index.xht
        index.xhtml
        index.cgi
        index.xml
        index.json
      ).freeze

      def serve
        Bridgetown::Deprecator.deprecation_message(
          "WEBrick (serve) will be removed in favor of Puma (start) in the next Bridgetown release"
        )

        @mutex = Mutex.new
        @run_cond = ConditionVariable.new
        @running = false

        no_watch = options["watch"] == false

        options = Thor::CoreExt::HashWithIndifferentAccess.new(self.options)
        options["serving"] = true
        options["watch"] = true unless no_watch

        config = configuration_with_overrides(options, Bridgetown::Current.preloaded_configuration)
        if Bridgetown.environment == "development"
          default_url(config).tap do |url|
            options["url"] = url
            config.url = url
          end
        end

        invoke(Build, [], options)
        start_server
      end

      protected

      def start_server
        destination = Bridgetown::Current.preloaded_configuration.destination
        setup(destination)

        start_up_webrick(destination)
      end

      def setup(destination)
        require_relative "serve/servlet"

        FileUtils.mkdir_p(destination)
        return unless File.exist?(File.join(destination, "404.html"))

        WEBrick::HTTPResponse.class_eval do
          def create_error_page
            @header["Content-Type"] = "text/html; charset=UTF-8"
            @body = File.read(File.join(@config[:DocumentRoot], "404.html"))
          end
        end
      end

      def webrick_opts(opts)
        opts = {
          BridgetownOptions: opts,
          DoNotReverseLookup: true,
          MimeTypes: mime_types,
          DocumentRoot: opts["destination"],
          StartCallback: start_callback(opts["detach"]),
          StopCallback: stop_callback(opts["detach"]),
          BindAddress: opts["host"],
          Port: opts["port"],
          DirectoryIndex: DIRECTORY_INDEX,
        }

        opts[:DirectoryIndex] = [] if opts[:BridgetownOptions]["show_dir_listing"]

        enable_ssl(opts)
        enable_logging(opts)
        opts
      end

      def start_up_webrick(destination)
        opts = Bridgetown::Current.preloaded_configuration
        @server = WEBrick::HTTPServer.new(webrick_opts(opts)).tap { |o| o.unmount("") }
        @server.mount(opts["base_path"].to_s, Servlet, destination, file_handler_opts)

        Bridgetown.logger.info "Server address:", server_address(@server, opts)
        launch_browser @server, opts if opts["open_url"]
        boot_or_detach @server, opts
      end

      def shutdown
        @server.shutdown if running?
      end

      def default_url(config)
        format_url(
          config["ssl_cert"] && config["ssl_key"],
          config["host"] == "127.0.0.1" ? "localhost" : config["host"],
          config["port"]
        )
      end

      def format_url(ssl_enabled, address, port, baseurl = nil)
        format("%<prefix>s://%<address>s:%<port>i%<baseurl>s",
               prefix: ssl_enabled ? "https" : "http",
               address: address,
               port: port,
               baseurl: baseurl ? "#{baseurl}/" : "")
      end

      # Recreate NondisclosureName under utf-8 circumstance
      def file_handler_opts
        WEBrick::Config::FileHandler.merge(
          FancyIndexing: true,
          NondisclosureName: [
            ".ht*", "~*",
          ]
        )
      end

      def server_address(server, options = {})
        format_url(
          server.config[:SSLEnable],
          server.config[:BindAddress],
          server.config[:Port],
          options["baseurl"]
        )
      end

      # Keep in our area with a thread or detach the server as requested
      # by the user.  This method determines what we do based on what you
      # ask us to do.
      def boot_or_detach(server, opts)
        if opts["detach"]
          pid = Process.fork do
            server.start
          end

          Process.detach(pid)
          Bridgetown.logger.info "Server detached with pid '#{pid}'.", \
                                 "Run `pkill -f bridgetown' or `kill -9 #{pid}' " \
                                 "to stop the server."
        else
          t = Thread.new { server.start }
          trap("INT") { server.shutdown }
          t.join
        end
      end

      # Make the stack verbose if the user requests it.
      def enable_logging(opts)
        opts[:AccessLog] = []
        level = WEBrick::Log.const_get(opts[:BridgetownOptions]["verbose"] ? :DEBUG : :WARN)
        opts[:Logger] = WEBrick::Log.new($stdout, level)
      end

      # Add SSL to the stack if the user triggers --enable-ssl and they
      # provide both types of certificates commonly needed.  Raise if they
      # forget to add one of the certificates.
      def enable_ssl(opts)
        cert, key, src =
          opts[:BridgetownOptions].values_at("ssl_cert", "ssl_key", "source")

        return if cert.nil? && key.nil?
        raise "Missing --ssl_cert or --ssl_key. Both are required." unless cert && key

        require "openssl"
        require "webrick/https"

        opts[:SSLCertificate] = OpenSSL::X509::Certificate.new(read_file(src, cert))
        begin
          opts[:SSLPrivateKey] = OpenSSL::PKey::RSA.new(read_file(src, key))
        rescue StandardError
          raise unless defined?(OpenSSL::PKey::EC)

          opts[:SSLPrivateKey] = OpenSSL::PKey::EC.new(read_file(src, key))
        end
        opts[:SSLEnable] = true
      end

      def start_callback(detached)
        return if detached

        proc do
          @mutex.synchronize do
            @running = true
            Bridgetown.logger.info("Server running…", "press ctrl-c to stop.")
            @run_cond.broadcast
          end
        end
      end

      def stop_callback(detached)
        return if detached

        proc do
          @mutex.synchronize do
            @running = false
            @run_cond.broadcast
          end
        end
      end

      def mime_types
        file = File.expand_path("../mime.types", __dir__)
        WEBrick::HTTPUtils.load_mime_types(file)
      end

      def read_file(source_dir, file_path)
        File.read(Bridgetown.sanitized_path(source_dir, file_path))
      end
    end
  end
end

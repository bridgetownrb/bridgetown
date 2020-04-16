# frozen_string_literal: true

module Bridgetown
  module Commands
    class Serve < Command
      # Similar to the pattern in Utils::ThreadEvent except we are maintaining the
      # state of @running instead of just signaling an event.  We have to maintain this
      # state since Serve is just called via class methods instead of an instance
      # being created each time.
      @mutex = Mutex.new
      @run_cond = ConditionVariable.new
      @running = false

      class << self
        COMMAND_OPTIONS = {
          "ssl_cert"           => ["--ssl-cert [CERT]", "X.509 (SSL) certificate."],
          "host"               => ["host", "-H", "--host [HOST]", "Host to bind to"],
          "open_url"           => ["-o", "--open-url", "Launch your site in a browser"],
          "detach"             => ["-B", "--detach",
                                   "Run the server in the background",],
          "ssl_key"            => ["--ssl-key [KEY]", "X.509 (SSL) Private Key."],
          "port"               => ["-P", "--port [PORT]", "Port to listen on"],
          "show_dir_listing"   => ["--show-dir-listing",
                                   "Show a directory listing instead of loading" \
                                   " your index file.",],
          "skip_initial_build" => ["skip_initial_build", "--skip-initial-build",
                                   "Skips the initial site build which occurs before" \
                                   " the server is started.",],
        }.freeze

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

        attr_reader :mutex, :run_cond, :running
        alias_method :running?, :running

        def init_with_program(prog)
          prog.command(:serve) do |cmd|
            cmd.description "Serve your site locally"
            cmd.syntax "serve [options]"
            cmd.alias :server
            cmd.alias :s

            add_build_options(cmd)
            COMMAND_OPTIONS.each do |key, val|
              cmd.option key, *val
            end

            cmd.action do |_, opts|
              opts["serving"] = true
              opts["watch"]   = true unless opts.key?("watch")

              # TODO: this prints the configuration file log message out-of-order
              config = configuration_from_options(opts)
              config["url"] = default_url(config) if Bridgetown.env == "development"

              process_with_graceful_fail(cmd, config, Build, Serve)
            end
          end
        end

        #

        def process(opts)
          opts = configuration_from_options(opts)
          destination = opts["destination"]
          setup(destination)

          start_up_webrick(opts, destination)
        end

        def shutdown
          @server.shutdown if running?
        end

        private

        # Do a base pre-setup of WEBRick so that everything is in place
        # when we get ready to party, checking for an setting up an error page
        # and making sure our destination exists.

        def setup(destination)
          require_relative "serve/servlet"

          FileUtils.mkdir_p(destination)
          if File.exist?(File.join(destination, "404.html"))
            WEBrick::HTTPResponse.class_eval do
              def create_error_page
                @header["Content-Type"] = "text/html; charset=UTF-8"
                @body = IO.read(File.join(@config[:DocumentRoot], "404.html"))
              end
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

        def start_up_webrick(opts, destination)
          @server = WEBrick::HTTPServer.new(webrick_opts(opts)).tap { |o| o.unmount("") }
          @server.mount(opts["baseurl"].to_s, Servlet, destination, file_handler_opts)

          Bridgetown.logger.info "Server address:", server_address(@server, opts)
          launch_browser @server, opts if opts["open_url"]
          boot_or_detach @server, opts
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

        def format_url(ssl_enabled, address, port, baseurl = nil)
          format("%<prefix>s://%<address>s:%<port>i%<baseurl>s",
                 prefix: ssl_enabled ? "https" : "http",
                 address: address,
                 port: port,
                 baseurl: baseurl ? "#{baseurl}/" : "")
        end

        def default_url(opts)
          config = configuration_from_options(opts)
          format_url(
            config["ssl_cert"] && config["ssl_key"],
            config["host"] == "127.0.0.1" ? "localhost" : config["host"],
            config["port"]
          )
        end

        def launch_browser(server, opts)
          address = server_address(server, opts)
          return system "start", address if Utils::Platforms.windows?
          return system "xdg-open", address if Utils::Platforms.linux?
          return system "open", address if Utils::Platforms.osx?

          Bridgetown.logger.error "Refusing to launch browser; " \
            "Platform launcher unknown."
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
                                   "Run `pkill -f bridgetown' or `kill -9 #{pid}'" \
                                   " to stop the server."
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
            if defined?(OpenSSL::PKey::EC)
              opts[:SSLPrivateKey] = OpenSSL::PKey::EC.new(read_file(src, key))
            else
              raise
            end
          end
          opts[:SSLEnable] = true
        end

        def start_callback(detached)
          unless detached
            proc do
              mutex.synchronize do
                @running = true
                Bridgetown.logger.info("Server running…", "press ctrl-c to stop.")
                @run_cond.broadcast
              end
            end
          end
        end

        def stop_callback(detached)
          unless detached
            proc do
              mutex.synchronize do
                @running = false
                @run_cond.broadcast
              end
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
end

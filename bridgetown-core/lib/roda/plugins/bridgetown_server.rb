# frozen_string_literal: true

class Roda
  module RodaPlugins
    module BridgetownServer
      SiteContext = Struct.new(:registers) # for use by Liquid-esque URL helpers

      def self.load_dependencies(app) # rubocop:disable Metrics
        unless Bridgetown::Current.preloaded_configuration
          raise "You must supply a preloaded configuration before loading the Bridgetown Roda " \
                "plugin"
        end

        app.extend ClassMethods # we need to do this here because Roda hasn't done it yet
        app.plugin :initializers
        app.plugin :method_override
        app.plugin :all_verbs
        app.plugin :hooks
        app.plugin :common_logger, Bridgetown::Rack::Logger.new($stdout), method: :info
        app.plugin :json
        app.plugin :json_parser
        app.plugin :indifferent_params
        app.plugin :cookies, path: "/"
        app.plugin :ssg, root: Bridgetown::Current.preloaded_configuration.destination
        app.plugin :not_found do
          output_folder = Bridgetown::Current.preloaded_configuration.destination
          File.read(File.join(output_folder, "404.html"))
        rescue Errno::ENOENT
          "404 Not Found"
        end
        app.plugin :exception_page
        app.plugin :error_handler do |e|
          Bridgetown::Errors.print_build_error(
            e, logger: Bridgetown::LogAdapter.new(self.class.opts[:common_logger]), server: true
          )
          next exception_page(e) if ENV.fetch("RACK_ENV", nil) == "development"

          output_folder = Bridgetown::Current.preloaded_configuration.destination
          File.read(File.join(output_folder, "500.html"))
        rescue Errno::ENOENT
          "500 Internal Server Error"
        end

        # TODO: there may be a better way to do this, see `exception_page_css` instance method
        ExceptionPage.class_eval do # rubocop:disable Metrics/BlockLength
          def self.css
            <<~CSS
              html * { padding:0; margin:0; }
              body * { padding:10px 20px; }
              body * * { padding:0; }
              body { font-family: -apple-system, sans-serif; font-size: 90%; }
              body>div { border-bottom:1px solid #ddd; }
              code { font-family: ui-monospace, monospace; }
              h1 { font-weight: bold; margin-block-end: .8em; }
              h2 { margin-block-end:.8em; }
              h2 span { font-size:80%; color:#f7f7db; font-weight:normal; }
              h3 { margin:1em 0 .5em 0; }
              h4 { margin:0 0 .5em 0; font-weight: normal; }
              table {
                  border:1px solid #ccc; border-collapse: collapse; background:white; }
              tbody td, tbody th { vertical-align:top; padding:2px 3px; }
              thead th {
                  padding:1px 6px 1px 3px; background:#fefefe; text-align:left;
                  font-weight:normal; font-size:11px; border:1px solid #ddd; }
              tbody th { text-align:right; opacity: 0.7; padding-right:.5em; }
              table.vars { margin:5px 0 2px 40px; }
              table.vars td, table.req td { font-family: ui-monospace, monospace; }
              table td.code { width:100%;}
              table td.code div { overflow:hidden; }
              table.source th { color:#666; }
              table.source td {
                  font-family: ui-monospace, monospace; white-space:pre; border-bottom:1px solid #eee; }
              ul.traceback { list-style-type:none; }
              ul.traceback li.frame { margin-bottom:1em; }
              div.context { margin: 10px 0; }
              div.context ol {
                  padding-left:30px; margin:0 10px; list-style-position: inside; }
              div.context ol li {
                  font-family: ui-monospace, monospace; white-space:pre; color:#666; cursor:pointer; }
              div.context ol.context-line li { color:black; background-color:#f7f7db; }
              div.context ol.context-line li span { float: right; }
              div.commands { margin-left: 40px; }
              div.commands a { color:black; text-decoration:none; }
              #summary { background: #1D453C; color: white; }
              #summary h2 { font-weight: normal; color: white; }
              #summary ul#quicklinks { list-style-type: none; margin-bottom: 2em; }
              #summary ul#quicklinks li { float: left; padding: 0 1em; }
              #summary ul#quicklinks>li+li { border-left: 1px #666 solid; }
              #summary a { color: #f47c3c; }
              #explanation { background:#eee; }
              #traceback { background: white; }
              #requestinfo { background:#f6f6f6; padding-left:120px; }
              #summary table { border:none; background:transparent; }
              #requestinfo h2, #requestinfo h3 { position:relative; margin-left:-100px; }
              #requestinfo h3 { margin-bottom:-1em; }
              .error { background: #ffc; }
              .specific { color:#cc3300; font-weight:bold; }
            CSS
          end
        end
      end

      module ClassMethods
        def root_hook(&block)
          opts[:root_hook] = block
        end
      end

      module InstanceMethods
        include Bridgetown::Foundation::RefinementsHelper

        def initialize_bridgetown_context
          if self.class.opts[:bridgetown_site]
            # The site had previously been initialized via the bridgetown_ssr plugin
            Bridgetown::Current.sites[self.class.opts[:bridgetown_site].label] =
              self.class.opts[:bridgetown_site]
            @context ||= SiteContext.new({ site: self.class.opts[:bridgetown_site] })
          end
          Bridgetown::Current.preloaded_configuration ||=
            self.class.opts[:bridgetown_preloaded_config]
        end

        def initialize_bridgetown_root # rubocop:todo Metrics/AbcSize
          request.root do
            hook_result = instance_exec(&self.class.opts[:root_hook]) if self.class.opts[:root_hook]
            next hook_result if hook_result

            status, headers, body = self.class.opts[:ssg_server].serving(
              request, File.join(self.class.opts[:ssg_root], "index.html")
            )
            response_headers = response.headers
            response_headers.replace(headers)

            request.halt [status, response_headers, body]
          rescue StandardError => e
            Bridgetown.logger.debug("Root handler error: #{e.message}")
            response.status = 500
            "<p>ERROR: cannot find <code>index.html</code> in the output folder.</p>"
          end
        end
      end

      Roda::RodaRequest.alias_method :_previous_roda_cookies, :cookies

      module RequestMethods
        # Monkeypatch Roda/Rack's Request object so it returns a hash which allows for
        # symbol or dot access
        def cookies
          HashWithDotAccess::Hash.new(_previous_roda_cookies)
        end

        # Start up the Bridgetown routing system
        def bridgetown
          scope.initialize_bridgetown_context
          scope.initialize_bridgetown_root

          # Run the static file server
          ssg

          # There are two different code paths depending on if there's a site `base_path` configured
          if Bridgetown::Current.preloaded_configuration.base_path == "/"
            Bridgetown::Rack::Routes.load_all scope
            return
          end

          # Support custom base_path configurations
          on(Bridgetown::Current.preloaded_configuration.base_path.delete_prefix("/")) do
            Bridgetown::Rack::Routes.load_all scope
          end

          nil
        end
      end
    end

    register_plugin :bridgetown_server, BridgetownServer
  end
end

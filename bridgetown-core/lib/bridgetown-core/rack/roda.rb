# frozen_string_literal: true

unless Bridgetown::Current.preloaded_configuration
  raise "You must supply a preloaded configuration before loading Bridgetown's Roda superclass"
end

module Bridgetown
  module Rack
    class Roda < ::Roda
      class << self
        def inherited(klass)
          super
          klass.plugin :initializers
        end

        # rubocop:disable Bridgetown/NoPutsAllowed
        def print_routes
          # TODO: this needs to be fully documented
          routes = begin
            JSON.parse(
              File.read(
                File.join(Bridgetown::Current.preloaded_configuration.root_dir, ".routes.json")
              )
            )
          rescue StandardError
            []
          end
          puts
          puts "Routes:"
          puts "======="
          if routes.blank?
            puts "No routes found. Have you commented all of your routes?"
            puts "Documentation: https://github.com/jeremyevans/roda-route_list#basic-usage-"
          end

          routes.each do |route|
            puts [
              route["methods"]&.join("|") || "GET",
              route["path"],
              route["file"] ? "\n  File: #{route["file"]}" : nil,
            ].compact.join(" ")
          end
          puts
        end
        # rubocop:enable Bridgetown/NoPutsAllowed
      end

      SiteContext = Struct.new(:registers) # for use by Liquid-esque URL helpers

      plugin :hooks
      plugin :common_logger, Bridgetown::Rack::Logger.new($stdout), method: :info
      plugin :json
      plugin :json_parser
      plugin :indifferent_params
      plugin :cookies
      plugin :streaming
      plugin :bridgetown_boot
      plugin :public, root: Bridgetown::Current.preloaded_configuration.destination
      plugin :not_found do
        output_folder = Bridgetown::Current.preloaded_configuration.destination
        File.read(File.join(output_folder, "404.html"))
      rescue Errno::ENOENT
        "404 Not Found"
      end
      plugin :exception_page
      plugin :error_handler do |e|
        Bridgetown::Errors.print_build_error(
          e, logger: Bridgetown::LogAdapter.new(self.class.opts[:common_logger])
        )
        next exception_page(e) if ENV.fetch("RACK_ENV", nil) == "development"

        output_folder = Bridgetown::Current.preloaded_configuration.destination
        File.read(File.join(output_folder, "500.html"))
      rescue Errno::ENOENT
        "500 Internal Server Error"
      end

      ::Roda::RodaPlugins::ExceptionPage.class_eval do
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

      before do
        if self.class.opts[:bridgetown_site]
          # The site had previously been initialized via the bridgetown_ssr plugin
          Bridgetown::Current.sites[self.class.opts[:bridgetown_site].label] =
            self.class.opts[:bridgetown_site]
          @context ||= SiteContext.new({ site: self.class.opts[:bridgetown_site] })
        end
        Bridgetown::Current.preloaded_configuration ||=
          self.class.opts[:bridgetown_preloaded_config]

        request.root do
          output_folder = Bridgetown::Current.preloaded_configuration.destination
          File.read(File.join(output_folder, "index.html"))
        rescue StandardError
          response.status = 500
          "<p>ERROR: cannot find <code>index.html</code> in the output folder.</p>"
        end
      end
    end
  end
end

# frozen_string_literal: true

require "uri"
require "rack/files"

class Roda
  module RodaPlugins
    # This is a simplifed and modified variant of Roda's Public core plugin. It adds additional
    # functionality so that you can host an entire static site through Roda. What's necessary for
    # this to work is handling "pretty" URLs, aka:
    #
    # /path/to/page -> /path/to/page.html or /path/to/page/index.html
    # /path/to/page/ -> /path/to/page/index.html
    #
    # It does not support serving compressed files, as that should ideally be handled through a
    # proxy or CDN layer in your architecture.
    module SSG
      PARSER = URI::DEFAULT_PARSER

      def self.configure(app, opts = {})
        app.opts[:ssg_root] = app.expand_path(opts.fetch(:root, "public"))
        app.opts[:ssg_server] = Rack::Files.new(app.opts[:ssg_root])
      end

      module RequestMethods
        def ssg
          return unless is_get?

          path = PARSER.unescape(real_remaining_path)
          return if path.include?("\0")

          server = roda_class.opts[:ssg_server]
          path = File.join(server.root, *segments_for_path(path))

          return unless File.file?(path)

          status, headers, body = server.serving(self, path)
          response_headers = response.headers
          response_headers.replace(headers)
          halt [status, response_headers, body]
        end

        # TODO: this could be refactored a bit
        def segments_for_path(path) # rubocop:disable Metrics/CyclomaticComplexity, Metrics/PerceivedComplexity
          segments = []

          path.split("/").each do |seg|
            next if seg.empty? || seg == "."

            seg == ".." ? segments.pop : segments << seg
          end

          path = File.join(roda_class.opts[:ssg_root], *segments)
          unless File.file?(path)
            path = File.join(path, "index.html")
            if File.file?(path)
              segments << "index.html"
            else
              segments[segments.size - 1] = "#{segments.last}.html"
            end
          end

          segments
        rescue IndexError
          nil
        end
      end
    end

    register_plugin :ssg, SSG
  end
end

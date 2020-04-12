# frozen_string_literal: true

require "webrick"

module Bridgetown
  module Commands
    class Serve
      class Servlet < WEBrick::HTTPServlet::FileHandler
        DEFAULTS = {
          "Cache-Control" => "private, max-age=0, proxy-revalidate, " \
            "no-store, no-cache, must-revalidate",
        }.freeze

        def initialize(server, root, callbacks)
          # So we can access them easily.
          @bridgetown_opts = server.config[:BridgetownOptions]
          set_defaults
          super
        end

        def search_index_file(req, res)
          super ||
            search_file(req, res, ".html") ||
            search_file(req, res, ".xhtml")
        end

        # Add the ability to tap file.html the same way that Nginx does on our
        # Docker images (or on GitHub Pages.) The difference is that we might end
        # up with a different preference on which comes first.

        def search_file(req, res, basename)
          # /file.* > /file/index.html > /file.html
          super ||
            super(req, res, "#{basename}.html") ||
            super(req, res, "#{basename}.xhtml")
        end

        # rubocop:disable Naming/MethodName
        def do_GET(req, res)
          rtn = super

          validate_and_ensure_charset(req, res)
          res.header.merge!(@headers)
          rtn
        end
        # rubocop:enable Naming/MethodName

        private

        def validate_and_ensure_charset(_req, res)
          key = res.header.keys.grep(%r!content-type!i).first
          typ = res.header[key]

          unless %r!;\s*charset=!.match?(typ)
            res.header[key] = "#{typ}; charset=#{@bridgetown_opts["encoding"]}"
          end
        end

        def set_defaults
          hash_ = @bridgetown_opts.fetch("webrick", {}).fetch("headers", {})
          DEFAULTS.each_with_object(@headers = hash_) do |(key, val), hash|
            hash[key] = val unless hash.key?(key)
          end
        end
      end
    end
  end
end

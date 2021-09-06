# frozen_string_literal: true

module Bridgetown
  module Routes
    module RodaRouter
      def self.start!(app)
        r = app.request
        response = app.response
        Bridgetown::Routes::Manifest.generate_manifest.each do |route|
          file, file_slug, segment_keys = route

          r.on file_slug do |*segment_values|
            response["X-Bridgetown-SSR"] = "1"
            unless Bridgetown.env.production? && Bridgetown::Routes::CodeBlocks.route_defined?(file_slug)
              eval_route_file file, file_slug, app
            end

            segment_values.each_with_index do |value, index|
              r.params[segment_keys[index]] ||= value
            end

            route_block = Bridgetown::Routes::CodeBlocks.route_block(file_slug)
            app.instance_variable_set(:@_route_file_code, route_block.instance_variable_get(:@_route_file_code)) # could be nil
            app.instance_exec(&route_block)
          end
        end

        nil
      end

      def self.eval_route_file(file, file_slug, app)
        code = File.read(file)
        code_postmatch = nil
        ruby_content = code.match(Bridgetown::FrontMatterImporter::RUBY_BLOCK)
        if ruby_content
          code = ruby_content[1]
          code_postmatch = ruby_content.post_match
        end

        app

        code = <<~RUBY
          r = app.request
          Bridgetown::Routes::CodeBlocks.add_route(#{file_slug.inspect}, #{code_postmatch.inspect}) do
            #{code}
          end
        RUBY
        instance_eval(code, file, -1)
      end
    end
  end
end

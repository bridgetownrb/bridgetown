# frozen_string_literal: true

class Roda
  module RodaPlugins
    module BridgetownRoutes
      def self.load_dependencies(app)
        app.plugin :slash_path_empty # now /hello and /hello/ are both matched
        app.plugin :placeholder_string_matchers
      end

      def self.configure(app, _opts = {})
        app.root_hook do
          routes_dir = File.expand_path(
            bridgetown_site.config.routes.source_paths.first,
            bridgetown_site.config.source
          )
          file = routes_manifest.glob_routes(routes_dir, "index").first
          next unless file

          run_file_route(file, slug: "index")
        end

        if app.opts[:bridgetown_site]
          app.opts[:routes_manifest] ||=
            Bridgetown::Routes::Manifest.new(app.opts[:bridgetown_site])
          return
        end

        raise "Roda app failure: the bridgetown_ssr plugin must be registered before " \
              "bridgetown_routes"
      end

      module InstanceMethods
        def routes_manifest
          self.class.opts[:routes_manifest]
        end

        def run_file_route(file, slug:)
          response["X-Bridgetown-Routes"] = "1"
          # eval_route_file caches when Bridgetown.env.production?
          Bridgetown::Routes::CodeBlocks.eval_route_file file, slug, self

          # set route locale
          locale = routes_manifest.locale_for(slug)
          I18n.locale = request.params[:locale] = locale

          # get the route block extracted from the file at slug
          route_block = Bridgetown::Routes::CodeBlocks.route_block(slug)
          response.instance_variable_set(
            :@_route_file_code, route_block.instance_variable_get(:@_route_file_code)
          ) # could be nil
          response.instance_variable_set(
            :@_front_matter_line_count,
            route_block.instance_variable_get(:@_front_matter_line_count)
          ) # could be nil
          instance_exec(request, &route_block)
        end

        def front_matter(&block)
          b = block.binding
          denylisted = %i(r argv)
          data = b.local_variables.filter_map do |key|
            next if denylisted.any? key

            [key, b.local_variable_get(key)]
          end.to_h

          Bridgetown::FrontMatter::RubyFrontMatter.new(data:, scope: self)
            .tap { _1.instance_exec(&block) }.to_h
        end

        def render_with(data: {}, &) # rubocop:todo Metrics/AbcSize, Metrics/MethodLength
          data = front_matter(&) if data.empty? && block_given?
          path = Kernel.caller_locations(1, 1).first.path
          source_path = Pathname.new(path).relative_path_from(
            bridgetown_site.in_source_dir("_routes")
          )
          code = response._route_file_code

          unless code.present?
            raise Bridgetown::Errors::FatalException,
                  "`render_with' method must be called from a template-based file in `src/_routes'"
          end

          data = Bridgetown::Model::BuilderOrigin.new(
            Bridgetown::Model::BuilderOrigin.id_for_builder_path(
              self, Addressable::URI.encode(source_path.to_s)
            )
          ).read do
            data[:_collection_] = bridgetown_site.collections.pages
            data[:_original_path_] = path
            data[:_relative_path_] = source_path
            data[:_front_matter_line_count_] = response._front_matter_line_count
            data[:_content_] = code
            data
          end

          Bridgetown::Model::Base.new(data).to_resource.tap do |resource|
            resource.roda_app = self
          end.read!
        end

        def render(...)
          view.render(...)
        end

        def view(*)
          Bridgetown::TemplateView.tap { _1.virtual_view.resource.roda_app = self }
        end
      end

      module RequestMethods
        # This runs through all of the routes in the manifest, setting up Roda blocks for execution
        def file_routes
          base_path = Bridgetown::Current.preloaded_configuration.base_path.delete_prefix("/")

          scope.routes_manifest.routes.each do |route|
            file, localized_file_slugs, segment_keys = route

            localized_file_slugs.each do |slug|
              on("") { scope.run_file_route(file, slug:) } if slug == "index" && !base_path.empty?

              # This sets up an initial Roda route block at the slug, and handles segments as params
              #
              # _routes/nested/[slug].erb -> "nested/:slug"
              # "nested/123" -> r.params[:slug] == 123
              on slug do |*segment_values|
                segment_values.each_with_index do |value, index|
                  params[segment_keys[index]] ||= value
                end

                # This is provided as an instance method by our Roda plugin:
                scope.run_file_route(file, slug:)
              end
            end
          end

          nil # be sure not to return the above array loop
        end
      end

      module ResponseMethods
        # template string provided, if available, by the saved code block
        def _route_file_code = @_route_file_code

        # we need to know where the real template starts for good error reporting
        def _front_matter_line_count = @_front_matter_line_count
      end
    end

    register_plugin :bridgetown_routes, BridgetownRoutes
  end
end

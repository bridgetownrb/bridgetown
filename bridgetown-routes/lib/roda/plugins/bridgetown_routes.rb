# frozen_string_literal: true

require "roda/plugins/flash"

class Roda
  module RodaPlugins
    module BridgetownRoutes
      def self.load_dependencies(app)
        app.plugin :slash_path_empty # now /hello and /hello/ are both matched
        app.plugin :placeholder_string_matchers
        app.plugin :flash
        app.plugin :route_csrf, check_header: true
      end

      def self.configure(app, _opts = {})
        if app.opts[:bridgetown_site].nil?
          raise "Roda app failure: the bridgetown_ssr plugin must be registered before bridgetown_routes"
        end
      end

      module InstanceMethods
        def render_with(data: {}) # rubocop:todo Metrics/AbcSize
          path = Kernel.caller_locations(1, 1).first.absolute_path
          source_path = Pathname.new(path).relative_path_from(Bridgetown::Current.site.source)
          code = @_route_file_code

          unless code.present?
            raise Bridgetown::Errors::FatalException,
                  "`render_with' method must be called from a template-based file in `src/_routes'"
          end

          data = Bridgetown::Model::BuilderOrigin.new("builder://#{source_path}").read do
            data[:_collection_] = Bridgetown::Current.site.collections.pages
            data[:_content_] = code
            data
          end

          Bridgetown::Model::Base.new(data).to_resource.tap do |resource|
            resource.roda_data[:request] = request
            resource.roda_data[:response] = response
            resource.roda_data[:flash] = nil
            #            resource.roda_data[:flash] = flash
          end.read!.transform!.output
        end

        ruby2_keywords def render(*args, &block)
          view.render(*args, &block)
        end

        def view(view_class: Bridgetown::ERBView)
          response._fake_resource_view(view_class: view_class, request: request, bridgetown_site: bridgetown_site)
        end
      end

      module ResponseMethods
        def _fake_resource_view(view_class:, request:, bridgetown_site:)
          @_fake_resource_views ||= {}
          @_fake_resource_views[view_class] ||= view_class.new(
            # TODO: use a Stuct for better performance...?
            HashWithDotAccess::Hash.new({
              data: {},
              roda_data: {
                request: request,
                response: self,
                flash: nil, # flash,
              },
              site: bridgetown_site,
            })
          )
        end
      end
    end

    register_plugin :bridgetown_routes, BridgetownRoutes
  end
end

module RodaResourceExtension
  module RubyResource
    def roda_data
      @roda_data ||= HashWithDotAccess::Hash.new
    end
  end
end
Bridgetown::Resource.register_extension RodaResourceExtension

Roda::RodaPlugins::Flash::FlashHash.class_eval do
  def info
    self["info"]
  end

  def info=(val)
    self["info"] = val
  end

  def alert
    self["alert"]
  end

  def alert=(val)
    self["alert"] = val
  end
end

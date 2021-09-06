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
        def render_with(data: {}, content: -1)
          path = Kernel.caller_locations(1, 1).first.absolute_path
          if content != -1 && File.extname(path) != ".rb"
            raise Bridgetown::Errors::FatalException,
                  "Only Ruby route files (.rb) support the `content' argument for `render_with'"
          end

          source_path = Pathname.new(path).relative_path_from(Bridgetown::Current.site.source)
          code = @_route_file_code || File.read(path)

          data = Bridgetown::Model::BuilderOrigin.new("builder://#{source_path}").read do
            data[:_collection_] = Bridgetown::Current.site.collections.pages
            data[:_content_] = content != -1 ? "<<-OUTPUT\n#{content}\nOUTPUT" : code
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
          fake_resource = HashWithDotAccess::Hash.new({
            data: {},
            roda_data: {
              request: request,
              response: response,
              flash: nil, # flash,
            },
            site: bridgetown_site,
          })
          view = Bridgetown::ERBView.new(fake_resource)
          view.render(*args, &block)
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

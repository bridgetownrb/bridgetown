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
        def render_with(data: {})
          path = Kernel.caller_locations(1, 1).first.absolute_path

          code = @_route_file_code || File.read(path)

          data = Bridgetown::Model::BuilderOrigin.new("builder://#{path}").read do
            data[:_collection_] = Bridgetown::Current.site.collections.pages
            data
          end

          model = Bridgetown::Model::Base.new(data.merge({
            _content_: code,
          }))

          model.to_resource.tap do |resource|
            resource.roda_data[:request] = request
            resource.roda_data[:response] = response
            #            resource.roda_data[:flash] = flash
          end.read!.transform!.output
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

# frozen_string_literal: true

class Roda
  module RodaPlugins
    module BridgetownCableCar
      def self.configure(_app, _opts = {})
        require "cable_ready"
      end

      module InstanceMethods
        def cable_car
          response["Content-Type"] = "application/vnd.cable-ready.json" if cable_ready?
          CableReady::CableCar.instance
        end

        def cable_ready?
          request.env["HTTP_ACCEPT"].include?("application/vnd.cable-ready.json")
        end

        def render_morph(data:, morph_wrapper: "morph-contents", **kwargs)
          data[:layout] = "none" if cable_ready? && data[:layout]

          @_morph_output = render_with data: data, will_morph: true, morph_wrapper: morph_wrapper

          return unless cable_ready?

          cable_car.morph(
            "morph-contents",
            html: @_morph_output,
            permanent_attribute_name: "data-morph-permanent",
            **kwargs
          )
        end

        def dispatch
          cable_ready? ? cable_car.dispatch : @_morph_output
        end
      end
    end

    register_plugin :cable_car, BridgetownCableCar
  end
end

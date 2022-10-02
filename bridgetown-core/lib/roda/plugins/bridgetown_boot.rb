# frozen_string_literal: true

class Roda
  module RodaPlugins
    module BridgetownBoot
      Roda::RodaRequest.alias_method :_previous_roda_cookies, :cookies

      module RequestMethods
        # Monkeypatch Roda/Rack's Request object so it returns a hash which allows for
        # indifferent access
        def cookies
          # TODO: maybe replace with a simpler hash that offers an overloaded `[]` method
          _previous_roda_cookies.with_indifferent_access
        end

        # Starts up the Bridgetown routing system
        def bridgetown
          Bridgetown::Rack::Routes.start!(scope)
        end
      end
    end

    register_plugin :bridgetown_boot, BridgetownBoot
  end
end

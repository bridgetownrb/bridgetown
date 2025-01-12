# frozen_string_literal: true

class Roda
  module RodaPlugins
    module Flashier
      module FlashHashAdditions
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

      module FlashHashIndifferent
        def []=(key, val)
          @next[key.to_s] = val
        end
      end

      module FlashNowHashIndifferent
        def []=(key, val)
          super(key.to_s, val)
        end

        def [](key)
          super(key.to_s)
        end
      end

      def self.load_dependencies(app)
        require "roda/plugins/flash"

        Roda::RodaPlugins::Flash::FlashHash.include FlashHashAdditions, FlashHashIndifferent
        Roda::RodaPlugins::Flash::FlashHash.class_eval do
          def initialize(hash = {})
            super(hash || {})
            now.singleton_class.include FlashHashAdditions, FlashNowHashIndifferent
            @next = {}
          end
        end
        app.plugin :flash
      end
    end

    register_plugin :flashier, Flashier
  end
end

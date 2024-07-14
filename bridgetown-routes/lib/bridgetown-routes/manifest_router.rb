# frozen_string_literal: true

module Bridgetown
  module Routes
    class ManifestRouter < Bridgetown::Rack::Routes
      priority :lowest

      route(&:file_routes)
    end
  end
end

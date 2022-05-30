# frozen_string_literal: true

class RodaApp < Bridgetown::Rack::Roda
  plugin :common_logger, StringIO.new # swallow logs in tests

  plugin :bridgetown_ssr do |site|
    site.data.iterations ||= 0
    site.data.iterations += 1
  end

  route(&:bridgetown)
end

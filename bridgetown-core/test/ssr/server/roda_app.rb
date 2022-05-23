# frozen_string_literal: true

class RodaApp < Bridgetown::Rack::Roda
  plugin :bridgetown_ssr do |site|
    site.data.iterations ||= 0
    site.data.iterations += 1
  end

  route do |r|
    r.bridgetown
  end
end

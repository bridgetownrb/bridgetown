class RodaApp < Bridgetown::Rack::Roda
  plugin :bridgetown_ssr

  route do |_r|
    Bridgetown::Rack::Routes.start! self
  end
end

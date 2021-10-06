class RodaApp < Bridgetown::Rack::Roda
  route do
    Bridgetown::Rack::Routes.start! self
  end
end

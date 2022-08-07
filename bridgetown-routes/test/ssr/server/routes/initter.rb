# frozen_string_literal: true

class Routes::Initter < Bridgetown::Rack::Routes
  priority :high

  route do |r|
    r.scope.instance_variable_set(:@answer_to_life, 42)
  end
end

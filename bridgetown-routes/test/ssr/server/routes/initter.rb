# frozen_string_literal: true

class Routes::Initter < Bridgetown::Rack::Routes
  using Bridgetown::Refinements

  priority :high

  route do |r|
    r.scope.instance_variable_set(:@answer_to_life, 40.add(2))
  end
end

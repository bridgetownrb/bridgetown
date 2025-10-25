module Documentation
  class Sidebar < Bridgetown::Component
    def initialize(docs:, resource:)
      @docs, @resource = docs, resource
    end
  end

  class VariablesTable < Bridgetown::Component
    def initialize(data:, scope:, description_size: :biggest)
      @vars = data.bridgetown_variables[scope]
      @size = description_size
    end
  end
end

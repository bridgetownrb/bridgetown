class Documentation::VariablesTable < Bridgetown::Component
  def initialize(data:, scope:, description_size: :biggest)
    @vars = data.bridgetown_variables[scope]
    @size = description_size
  end
end

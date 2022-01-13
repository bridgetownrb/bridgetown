class Documentation::Sidebar < Bridgetown::Component
  def initialize(docs:, resource:)
    @docs, @resource = docs, resource
  end
end

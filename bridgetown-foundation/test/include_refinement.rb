# frozen_string_literal: true

module Adding
  refine Numeric do
    def add(input)
      self + input
    end
  end
end

Bridgetown.add_refinement(Adding) do
  # boilerplate
  using Bridgetown::Refinements
  def method_missing(...) = __getobj__.send(...) # rubocop:disable Style
end

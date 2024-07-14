# frozen_string_literal: true

module Adding
  refine Numeric do
    def add(input)
      self + input
    end
  end
end

module BunchOfRefinements
  include Adding
end

Bridgetown.add_refinement(BunchOfRefinements) do
  # boilerplate
  using Bridgetown::Refinements
  def method_missing(method, ...) = __getobj__.send(method, ...) # rubocop:disable Style
end

module DoubleNumbers
  include Bridgetown::Refinements::Helper

  def double
    self * refine(1).add(1)
  end
end
Numeric.include DoubleNumbers

class DoublingArray < Array
  def double_map
    map(&:double)
  end
end

r.get Integer do |num|
  numbers = DoublingArray.new([1, 2, 3, num]).double_map

  { numbers: }
end

# frozen_string_literal: true

require "benchmark"

class TestInclusion
  module StringAdder
    def included_add(num)
      to_i + num
    end
  end

  String.include StringAdder

  def self.perform
    raise "crash!" unless "10".included_add(20) == 30
  end
end

module StringAdderRefinement
  refine String do
    def refined_add(num)
      to_i + num
    end
  end
end

class TestRefinement
  using StringAdderRefinement

  def self.perform
    raise "crash!" unless "10".refined_add(20) == 30
  end
end

raise "Unconfirmed!" unless "".respond_to?(:included_add)
raise "Unconfirmed!" if "".respond_to?(:refined_add)

n = 1_000_000
Benchmark.bmbm(12) do |x|
  x.report("inclusion:") do
    n.times do
      TestInclusion.perform
    end
  end
  x.report("refinements:") do
    n.times do
      TestRefinement.perform
    end
  end
end

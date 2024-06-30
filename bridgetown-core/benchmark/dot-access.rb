#!/usr/bin/env ruby
# frozen_string_literal: true

require "bundler"
Bundler.setup
require "benchmark/ips"
require "active_support/core_ext/hash/indifferent_access"
require "hash_with_dot_access"

class User < HashWithDotAccess::Hash
end

user = User.new({ address: { category: { desc: "Urban" } } })

using HashWithDotAccess::Refinements

# Enable and start GC before each job run. Disable GC afterwards.
#
# Inspired by https://www.omniref.com/ruby/2.2.1/symbols/Benchmark/bm?#annotation=4095926&line=182
class GCSuite
  def warming(*)
    run_gc
  end

  def running(*)
    run_gc
  end

  def warmup_stats(*); end

  def add_report(*); end

  private

  def run_gc
    GC.enable
    GC.start
    GC.disable
  end
end

suite = GCSuite.new

Benchmark.ips do |x|
  x.config(suite:, time: 1, warmup: 1)

  x.report("standard hash") do
    h = { "foo" => "bar" }
    h["foo"]
  end
  x.report("standard hash with fetch") do
    h = { "foo" => "bar" }
    h.fetch("foo", nil)
  end
  x.report("standard hash - symbol keys") do
    h = { foo: "bar" }
    h[:foo]
  end
  x.report("standard hash with fetch - symbol keys") do
    h = { foo: "bar" }
    h.fetch(:foo, nil)
  end
  x.report("hash with indifferent access string") do
    h = { "foo" => "bar" }.with_indifferent_access
    h["foo"]
  end
  x.report("hash with indifferent access symbol") do
    h = { "foo" => "bar" }.with_indifferent_access
    h[:foo]
  end
  x.report("hash with indifferent access via new method") do
    h = ActiveSupport::HashWithIndifferentAccess.new({ "foo" => "bar" })
    h[:foo]
  end
  # x.report("hash with indifferent access via []") do
  #   h = ActiveSupport::HashWithIndifferentAccess[{ "foo" => "bar" }]
  #   h[:foo]
  # end
  x.report("hash as_dots and symbol access") do
    h = { foo: "bar" }.as_dots
    h[:foo]
  end
  x.report("hash as_dots and method access") do
    h = { foo: "bar" }.as_dots
    h.foo
  end
  x.report("hash with dot access new method, string init, and symbol access") do
    h = HashWithDotAccess::Hash.new({ "foo" => "bar" })
    h[:foo]
  end
  x.report("hash with dot access new method, symbol init, and method access") do
    h = HashWithDotAccess::Hash.new(foo: "bar")
    h.foo
  end
  x.report("hash with dot access new method, string access") do
    h = HashWithDotAccess::Hash.new({ "foo" => "bar" })
    h["foo"]
  end
    user = { address: { category: { desc: "Urban" } } }
  x.report("nested symbols") do
    user[:address][:category][:desc]
  end
    userd = User.new({ address: { category: { desc: "Urban" } } })
  x.report("nested dots") do
    userd.address.category.desc
  end
  x.compare!
end

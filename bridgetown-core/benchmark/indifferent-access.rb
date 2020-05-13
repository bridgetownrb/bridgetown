#!/usr/bin/env ruby
# frozen_string_literal: true

require "benchmark/ips"
require "active_support/core_ext/hash/indifferent_access"

Benchmark.ips do |x|
  x.config(time: 1, warmup: 1)

  x.report("standard hash") do
    h = { "foo" => "bar" }
    h["foo"]
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
    h = ActiveSupport::HashWithIndifferentAccess.new
    h["foo"] = "bar"
    h[:foo]
  end
  x.compare!
end

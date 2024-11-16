#!/usr/bin/env ruby
# frozen_string_literal: true

require "bundler"
Bundler.setup
require "benchmark/ips"
require "bridgetown"

include ::Streamlined::Renderable

def erb_out
  @erbtmpl ||= Tilt::ErubiTemplate.new(
    outvar: "@_erbout",
    bufval: "Bridgetown::OutputBuffer.new",
    engine_class: Bridgetown::ERBEngine
  ) { erb_content }
  @erbtmpl.render(self)
end

def erb_content
  <<~ERB
  <p><%= 123 + 99 %></p>
  <%= erb2_out %>
  ERB
end

def erb2_out
  @erb2tmpl ||= Tilt::ErubiTemplate.new(
    outvar: "@_erbout",
    bufval: "Bridgetown::OutputBuffer.new",
    engine_class: Bridgetown::ERBEngine
  ) { erb2_content }
  @erb2tmpl.render(self)
end

def erb2_content
  <<~ERB
  <p><%= version %></p>
  ERB
end

def streamlined_out
  html -> { <<~HTML
  <p>#{text -> { 123 + 99 }}</p>
  #{html -> { streamlined2_out }}
  HTML
  }
end

def streamlined2_out
  <<~HTML
  <p>#{text -> { version }}</p>
  HTML
end

def version
  "<s>#{Bridgetown::VERSION}</s>"
end

puts erb_out
puts "---"
puts streamlined_out.to_s

Benchmark.ips do |x|
  x.report("erb") { erb_out }
  x.report("streamlined") { streamlined_out.to_s }
end

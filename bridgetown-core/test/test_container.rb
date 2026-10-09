# frozen_string_literal: true

require "helper"

class TestContainer < BridgetownUnitTest
  class TestRoutine
    def initialize(key)
      @key = key
    end

    def execute(instance)
      instance.ready!
      loop do
        sleep 1
      end
    end

    def name = "Test Container"
    def key  = @key # rubocop:disable Style/TrivialAccessors
  end

  before do
    ENV["CONSOLE_OFF"] = "Bridgetown::Container"
    @container = Bridgetown::Container.new
  end

  after do
    @container.stop if @container.running?
  end

  it "spawns processes for all added routines" do
    @container.add_routine(TestRoutine.new("1"))
    @container.add_routine(TestRoutine.new("2"))
    @container.add_routine(TestRoutine.new("3"))

    @container.run

    assert_equal 3, @container.statistics.spawns
    assert_equal 3, @container.state.size
  end

  it "stops when a child process exits" do
    @container.add_routine(TestRoutine.new("1"))
    @container.add_routine(TestRoutine.new("2"))
    @container.add_routine(TestRoutine.new("3"))

    @container.run

    pid = @container["1"].pid
    Process.kill("INT", pid)

    @container.wait

    refute @container.running?
  end
end

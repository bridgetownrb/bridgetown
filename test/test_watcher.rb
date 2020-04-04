# frozen_string_literal: true

require "mercenary"
require "helper"

# TODO: we need a bunch more tests added here!
class TestWatcher < BridgetownUnitTest
  context "watching the site" do
    setup do
      @merc = nil
      @cmd = Bridgetown::Commands::Build
      Mercenary.program(:bridgetown) do |p|
        @merc = @cmd.init_with_program(
          p
        )
      end
    end

    should "build and start watching" do
      @merc.execute(:build, "watch" => false) # watch should be true!
      assert_equal @merc.name, :build
    end
  end
end

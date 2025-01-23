# frozen_string_literal: true

require "helper"
require_all "bridgetown-core/commands/concerns"
require "bridgetown-core/commands/plugins"

class TestPluginsCommand < BridgetownUnitTest
  context "list registered plugins" do
    setup do
      fixture_site
      @cmd = Bridgetown::Commands::Plugins.new
    end

    should "exclude init (Initializer) from registered plugins list" do
      out, err = capture_io do
        @cmd.invoke(:list)
      end

      assert_nil err
      refute_includes "init (Initializer)", out
    end

    should "exclude init (Initializer) from registered plugins count" do
      out, err = capture_io do
        @cmd.invoke(:list)
      end

      assert_nil err
      assert_includes "Registered Plugins: 3", out
    end
  end
end

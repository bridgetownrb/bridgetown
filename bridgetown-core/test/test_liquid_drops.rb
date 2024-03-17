# frozen_string_literal: true

require "helper"

class DropFixture < Bridgetown::Drops::Drop
  mutable true

  def foo
    "bar"
  end

  def fallback_data
    @fallback_data ||= { "baz" => "buzz" }
  end
end

class TestLiquidDrops < BridgetownUnitTest
  context "Drops" do
    setup do
      @site = fixture_site(
        "collections" => ["methods"]
      )
      @site.process
      @resource = @site.collections["methods"].resources.detect do |d|
        d.relative_path.to_s == "_methods/configuration.md"
      end
      @resource_drop = @resource.to_liquid
      @drop = DropFixture.new({})
    end

    should "reject 'nil' key" do
      refute @drop.key?(nil)
    end

    should "return values for #[]" do
      assert_equal "bar", @drop["foo"]
    end

    should "return values for #invoke_drop" do
      assert_equal "bar", @drop.invoke_drop("foo")
    end

    context "mutations" do
      should "return mutations for #[]" do
        @drop["foo"] = "baz"
        assert_equal "baz", @drop["foo"]
      end

      should "return mutations for #invoke_drop" do
        @drop["foo"] = "baz"
        assert_equal "baz", @drop.invoke_drop("foo")
      end
    end

    context "a resource drop" do
      context "fetch" do
        should "raise KeyError if key is not found and no default provided" do
          assert_raises KeyError do
            @resource_drop.fetch("not_existing_key")
          end
        end

        should "fetch value without default" do
          assert_equal "Bridgetown.configuration", @resource_drop.fetch("title")
        end

        should "fetch default if key is not found" do
          assert_equal "default", @resource_drop.fetch("not_existing_key", "default")
        end

        should "fetch default boolean value correctly" do
          assert_equal false, @resource_drop.fetch("bar", false)
        end

        should "fetch default value from block if key is not found" do
          assert_equal "default bar", @resource_drop.fetch("bar") { |el| "default #{el}" }
        end

        should "fetch default value from block first if both argument and block given" do
          assert_equal "baz", @resource_drop.fetch("bar", "default") { "baz" }
        end

        should "not change mutability when fetching" do
          assert @drop.class.mutable?
          @drop["foo"] = "baz"
          assert_equal "baz", @drop.fetch("foo")
          assert @drop.class.mutable?
        end
      end
    end

    context "key?" do
      context "a mutable drop" do
        should "respond true for native methods" do
          assert @drop.key? "foo"
        end

        should "respond true for mutable keys" do
          @drop["bar"] = "baz"
          assert @drop.key? "bar"
        end

        should "return true for fallback data" do
          assert @drop.key? "baz"
        end
      end

      context "a resource drop" do
        should "respond true for native methods" do
          assert @resource_drop.key? "collection"
        end

        should "return true for fallback data" do
          assert @resource_drop.key? "title"
        end
      end
    end
  end

  context "a site drop" do
    setup do
      @site = fixture_site(
        "collections" => ["thanksgiving"]
      )
      @site.process
      @drop = @site.to_liquid.site
    end

    should "respond to `key?`" do
      assert @drop.respond_to?(:key?)
    end

    should "find a key if it's in the collection of the drop" do
      assert @drop["collections"].key?("thanksgiving")
    end
  end
end

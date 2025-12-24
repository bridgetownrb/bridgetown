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
  describe "Drops" do
    before do
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

    it "rejects 'nil' key" do
      refute @drop.key?(nil)
    end

    it "returns values for #[]" do
      assert_equal "bar", @drop["foo"]
    end

    it "returns values for #invoke_drop" do
      assert_equal "bar", @drop.invoke_drop("foo")
    end

    describe "mutations" do
      it "returns mutations for #[]" do
        @drop["foo"] = "baz"
        assert_equal "baz", @drop["foo"]
      end

      it "returns mutations for #invoke_drop" do
        @drop["foo"] = "baz"
        assert_equal "baz", @drop.invoke_drop("foo")
      end
    end

    describe "a resource drop" do
      describe "fetch" do
        it "raises KeyError if key is not found and no default provided" do
          assert_raises KeyError do
            @resource_drop.fetch("not_existing_key")
          end
        end

        it "fetches value without default" do
          assert_equal "Bridgetown.configuration", @resource_drop.fetch("title")
        end

        it "fetches default if key is not found" do
          assert_equal "default", @resource_drop.fetch("not_existing_key", "default")
        end

        it "fetches default boolean value correctly" do
          assert_equal false, @resource_drop.fetch("bar", false)
        end

        it "fetches default value from block if key is not found" do
          assert_equal "default bar", @resource_drop.fetch("bar") { |el| "default #{el}" }
        end

        it "fetches default value from block first if both argument and block given" do
          assert_equal "baz", @resource_drop.fetch("bar", "default") { "baz" } # rubocop:disable Lint/UselessDefaultValueArgument
        end

        it "does not change mutability when fetching" do
          assert @drop.class.mutable?
          @drop["foo"] = "baz"
          assert_equal "baz", @drop.fetch("foo")
          assert @drop.class.mutable?
        end
      end
    end

    describe "key?" do
      describe "a mutable drop" do
        it "responds true for native methods" do
          assert @drop.key? "foo"
        end

        it "responds true for mutable keys" do
          @drop["bar"] = "baz"
          assert @drop.key? "bar"
        end

        it "returns true for fallback data" do
          assert @drop.key? "baz"
        end
      end

      describe "a resource drop" do
        it "responds true for native methods" do
          assert @resource_drop.key? "collection"
        end

        it "returns true for fallback data" do
          assert @resource_drop.key? "title"
        end
      end
    end
  end

  describe "a site drop" do
    before do
      @site = fixture_site(
        "collections" => ["thanksgiving"]
      )
      @site.process
      @drop = @site.to_liquid.site
    end

    it "responds to `key?`" do
      assert @drop.respond_to?(:key?)
    end

    it "finds a key if it's in the collection of the drop" do
      assert @drop["collections"].key?("thanksgiving")
    end
  end
end

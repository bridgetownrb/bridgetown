# frozen_string_literal: true

require "webrick"
require "mercenary"
require "helper"
require "httpclient"
require "openssl"
require "tmpdir"

class TestCommandsServe < BridgetownUnitTest
  def custom_opts(what)
    @cmd.send(
      :webrick_opts, what
    )
  end

  def start_server(opts)
    @thread = Thread.new do
      merc = nil
      cmd = Bridgetown::Commands::Serve
      Mercenary.program(:bridgetown) do |p|
        merc = cmd.init_with_program(p)
      end
      merc.execute(:serve, opts)
    end
    @thread.abort_on_exception = true

    Bridgetown::Commands::Serve.mutex.synchronize do
      unless Bridgetown::Commands::Serve.running?
        Bridgetown::Commands::Serve.run_cond.wait(Bridgetown::Commands::Serve.mutex)
      end
    end
  end

  def serve(opts)
    allow(Bridgetown).to receive(:configuration).and_return(opts)
    allow(Bridgetown::Commands::Build).to receive(:process)

    start_server(opts)

    opts
  end

  context "with a program" do
    setup do
      @merc = nil
      @cmd = Bridgetown::Commands::Serve
      Mercenary.program(:bridgetown) do |p|
        @merc = @cmd.init_with_program(
          p
        )
      end
      Bridgetown.sites.clear
      allow(SafeYAML).to receive(:load_file).and_return({})
      allow(Bridgetown::Commands::Build).to receive(:build).and_return("")
    end
    teardown do
      Bridgetown.sites.clear
    end

    should "label itself" do
      assert_equal :serve, @merc.name
    end

    should "have aliases" do
      assert_includes @merc.aliases, :s
      assert_includes @merc.aliases, :server
    end

    should "have a description" do
      refute_nil(
        @merc.description
      )
    end

    should "have an action" do
      refute_empty(
        @merc.actions
      )
    end

    should "not have an empty options set" do
      refute_empty(
        @merc.options
      )
    end

    context "with custom options" do
      should "create a default set of mimetypes" do
        refute_nil custom_opts({})[
          :MimeTypes
        ]
      end

      should "use user destinations" do
        assert_equal "foo", custom_opts("destination" => "foo")[
          :DocumentRoot
        ]
      end

      should "use user port" do
        # WHAT?!?!1 Over 9000? That's impossible.
        assert_equal 9001, custom_opts("port" => 9001)[
          :Port
        ]
      end

      should "use empty directory index list when show_dir_listing is true" do
        opts = { "show_dir_listing" => true }
        assert custom_opts(opts)[:DirectoryIndex].empty?
      end

      should "keep config between build and serve" do
        options = {
          "config"  => %w(_config.yml _development.yml),
          "serving" => true,
          "watch"   => false, # for not having guard output when running the tests
          "url"     => "http://localhost:4000",
        }
        config = Bridgetown::Configuration.from(options)

        allow(Bridgetown::Command).to(
          receive(:configuration_from_options).with(options).and_return(config)
        )
        allow(Bridgetown::Command).to(
          receive(:configuration_from_options).with(config).and_return(config)
        )

        expect(Bridgetown::Commands::Build).to(
          receive(:process).with(config).and_call_original
        )
        expect(Bridgetown::Commands::Serve).to receive(:process).with(config)
        @merc.execute(:serve, options)
      end

      context "in development environment" do
        setup do
          expect(Bridgetown).to receive(:env).and_return("development")
          expect(Bridgetown::Commands::Serve).to receive(:start_up_webrick)
        end
        should "set the site url by default to `http://localhost:4000`" do
          @merc.execute(:serve, "watch" => false, "url" => "https://bridgetownrb.com/")

          assert_equal 1, Bridgetown.sites.count
          assert_equal "http://localhost:4000", Bridgetown.sites.first.config["url"]
        end

        should "take `host`, `port` and `ssl` into consideration if set" do
          @merc.execute(:serve,
                        "watch"    => false,
                        "host"     => "example.com",
                        "port"     => "9999",
                        "url"      => "https://bridgetownrb.com/",
                        "ssl_cert" => "foo",
                        "ssl_key"  => "bar")

          assert_equal 1, Bridgetown.sites.count
          assert_equal "https://example.com:9999", Bridgetown.sites.first.config["url"]
        end
      end

      context "not in development environment" do
        should "not update the site url" do
          expect(Bridgetown).to receive(:env).and_return("production")
          expect(Bridgetown::Commands::Serve).to receive(:start_up_webrick)
          @merc.execute(:serve, "watch" => false, "url" => "https://bridgetownrb.com/")

          assert_equal 1, Bridgetown.sites.count
          assert_equal "https://bridgetownrb.com/", Bridgetown.sites.first.config["url"]
        end
      end

      context "verbose" do
        should "debug when verbose" do
          assert_equal 5, custom_opts("verbose" => true)[:Logger].level
        end

        should "warn when not verbose" do
          assert_equal 3, custom_opts({})[:Logger].level
        end
      end

      context "enabling SSL" do
        should "raise if enabling without key or cert" do
          assert_raises RuntimeError do
            custom_opts(
              "ssl_key" => "foo"
            )
          end

          assert_raises RuntimeError do
            custom_opts(
              "ssl_key" => "foo"
            )
          end
        end

        should "allow SSL with a key and cert" do
          expect(OpenSSL::PKey::RSA).to receive(:new).and_return("c2")
          expect(OpenSSL::X509::Certificate).to receive(:new).and_return("c1")
          allow(File).to receive(:read).and_return("foo")

          result = custom_opts(
            "ssl_cert"   => "foo",
            "source"     => "bar",
            "enable_ssl" => true,
            "ssl_key"    => "bar"
          )

          assert result[:SSLEnable]
          assert_equal "c2", result[:SSLPrivateKey]
          assert_equal "c1", result[:SSLCertificate]
        end
      end
    end

    should "read `configuration` only once" do
      allow(Bridgetown::Commands::Serve).to receive(:start_up_webrick)

      expect(Bridgetown).to receive(:configuration).once.and_call_original
      @merc.execute(:serve, "watch" => false)
    end
  end
end

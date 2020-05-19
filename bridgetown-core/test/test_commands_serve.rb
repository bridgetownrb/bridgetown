# frozen_string_literal: true

require "webrick"
require "helper"
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
      @cmd = Bridgetown::Commands::Serve.new
      Bridgetown.sites.clear
      allow(SafeYAML).to receive(:load_file).and_return({})
      allow_any_instance_of(Bridgetown::Commands::Build).to receive(:build)
      allow_any_instance_of(Bridgetown::Commands::Serve).to receive(:start_up_webrick)
    end
    teardown do
      Bridgetown.sites.clear
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

      context "in development environment" do
        setup do
          allow(Bridgetown).to receive_messages(environment: "development")
        end
        should "set the site url by default to `http://localhost:4000`" do
          @cmd.options = { "watch" => false, "url" => "https://bridgetownrb.com/" }.with_indifferent_access
          @cmd.serve

          assert_equal 1, Bridgetown.sites.count
          assert_equal "http://localhost:4000", Bridgetown.sites.first.config["url"]
        end

        should "take `host`, `port` and `ssl` into consideration if set" do
          @cmd.options = { "watch"    => false,
                           "host"     => "example.com",
                           "port"     => "9999",
                           "url"      => "https://bridgetownrb.com/",
                           "ssl_cert" => "foo",
                           "ssl_key"  => "bar", }.with_indifferent_access
          @cmd.serve

          assert_equal 1, Bridgetown.sites.count
          assert_equal "https://example.com:9999", Bridgetown.sites.first.config["url"]
        end
      end

      context "not in development environment" do
        should "not update the site url" do
          @cmd.options = { "watch" => false, "url" => "https://bridgetownrb.com/" }.with_indifferent_access
          allow(Bridgetown).to receive_messages(environment: "production")
          @cmd.serve

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
      expect(Bridgetown).to receive(:configuration).once.and_call_original
      @cmd.options = { "watch" => false }.with_indifferent_access
      @cmd.serve
    end
  end
end

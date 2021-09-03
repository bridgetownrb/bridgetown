# frozen_string_literal: true

class Bridgetown::Site
  module Processable
    # Reset, Read, Generate, Render, Cleanup, Process, and Write this Site to output.
    # @return [void]
    # @see #reset
    # @see #read
    # @see #generate
    # @see #render
    # @see #cleanup
    # @see #write
    def process
      Bridgetown::Current.site = self
      reset
      read
      generate  # Extensible
      render    # Renderable
      cleanup   # Writable
      write     # Writable
      print_stats if config["profile"]
    end

    # Reset all in-memory data and content.
    # @return [void]
    def reset
      self.time = Time.now
      if config["time"]
        self.time = Bridgetown::Utils.parse_date(
          config["time"].to_s, "Invalid time in bridgetown.config.yml."
        )
      end
      self.layouts = HashWithDotAccess::Hash.new
      self.pages = []
      self.static_files = []
      self.data = HashWithDotAccess::Hash.new
      @frontend_manifest = nil
      @post_attr_hash = {}
      @collections = nil
      @documents = nil
      @docs_to_write = nil
      @regenerator.clear_cache
      @liquid_renderer.reset
      frontmatter_defaults.reset

      Bridgetown::Cache.clear_if_config_changed config
      Bridgetown::Hooks.trigger :site, :after_reset, self
    end

    # Read data from disk and load it into internal memory.
    # @return [void]
    def read
      Bridgetown::Hooks.trigger :site, :pre_read, self
      reader.read
      limit_posts!
      Bridgetown::Hooks.trigger :site, :post_read, self
    end

    private

    # Limits the current posts; removes the posts which exceed the limit_posts
    def limit_posts!
      if config.limit_posts.positive?
        Bridgetown::Deprecator.deprecation_message(
          "The limit_posts config option will be removed prior to Bridgetown 1.0"
        )
        limit = posts.docs.length < config.limit_posts ? posts.docs.length : config.limit_posts
        posts.docs = posts.docs[-limit, limit]
      end
    end

    def print_stats
      Bridgetown.logger.info @liquid_renderer.stats_table
    end
  end
end

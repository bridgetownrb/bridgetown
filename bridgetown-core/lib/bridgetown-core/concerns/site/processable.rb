# frozen_string_literal: true

module Bridgetown
  module Site::Processable
    # Reset, Read, Generate, Render, Cleanup, Process, and Write this Site to output.
    # @return [void]
    # @see #reset
    # @see #read
    # @see #generate
    # @see #render
    # @see #cleanup
    # @see #write
    def process
      reset
      read
      generate  # Extensible
      render    # Renderable
      cleanup   # Writable
      write     # Writable
      print_stats if config["profile"]
    end

    # rubocop:disable Metrics/AbcSize

    # Reset Site details.
    # @return [void]
    def reset
      self.time = if config["time"]
                    Utils.parse_date(config["time"].to_s, "Invalid time in bridgetown.config.yml.")
                  else
                    Time.now
                  end
      self.layouts = ActiveSupport::HashWithIndifferentAccess.new
      self.pages = []
      self.static_files = []
      self.data = ActiveSupport::HashWithIndifferentAccess.new
      @post_attr_hash = {}
      @collections = nil
      @documents = nil
      @docs_to_write = nil
      @regenerator.clear_cache
      @liquid_renderer.reset
      frontmatter_defaults.reset

      raise ArgumentError, "limit_posts must be a non-negative number" if limit_posts.negative?

      Bridgetown::Cache.clear_if_config_changed config
      Bridgetown::Hooks.trigger :site, :after_reset, self
    end

    # rubocop:enable Metrics/AbcSize

    # Read Site data from disk and load it into internal data structures.
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
      if limit_posts.positive?
        limit = posts.docs.length < limit_posts ? posts.docs.length : limit_posts
        posts.docs = posts.docs[-limit, limit]
      end
    end

    def print_stats
      Bridgetown.logger.info @liquid_renderer.stats_table
    end
  end
end

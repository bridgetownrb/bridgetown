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
    #

    # @return [void]
    def reset(soft: false)
      self.time = Time.now
      if config["time"]
        self.time = Bridgetown::Utils.parse_date(
          config["time"].to_s, "Invalid time in bridgetown.config.yml."
        )
      end
      self.layouts = HashWithDotAccess::Hash.new
      self.generated_pages = []
      self.static_files = []
      self.data = HashWithDotAccess::Hash.new unless soft
      @frontend_manifest = nil
      @collections = nil
      @documents = nil
      @docs_to_write = nil
      @liquid_renderer.reset
      frontmatter_defaults.reset unless soft

      Bridgetown::Cache.clear_if_config_changed config unless soft
      Bridgetown::Hooks.trigger :site, (soft ? :after_soft_reset : :after_reset), self
    end

    # Read data from disk and load it into internal memory.
    # @return [void]
    def read
      Bridgetown::Hooks.trigger :site, :pre_read, self
      reader.read
      Bridgetown::Hooks.trigger :site, :post_read, self
    end

    private

    def print_stats
      Bridgetown.logger.info @liquid_renderer.stats_table
    end
  end
end

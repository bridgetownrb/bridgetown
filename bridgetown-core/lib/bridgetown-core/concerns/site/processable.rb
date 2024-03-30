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
      reset
      read
      generate  # Extensible
      render    # Renderable
      cleanup   # Writable
      write     # Writable
      print_stats if config["profile"]
    end

    def fast_refresh(paths = [], reload_if_needed: false)
      FileUtils.rm_f(Bridgetown.build_errors_path)

      @fast_refresh_ordering = 0
      found_gen_pages = false
      paths.each do |path|
        res = resources.find do |resource|
          resource.id.start_with?("repo://") && in_source_dir(resource.relative_path) == path
        end

        layouts_to_reload = Set.new
        unless res
          resources.each do |resource|
            next unless resource.data.layout

            res_layouts = validated_layouts_for(resource, resource.data.layout)
              .select { _1.path == path }
            next unless res_layouts.length.positive?

            res_layouts.each { layouts_to_reload << _1 }
            resource.mark_for_fast_refresh!
          end
        end

        pages = generated_pages.select do |pg|
          next unless pg.respond_to?(:page_to_copy)

          found =
            if pg.page_to_copy.respond_to?(:prototyped_page)
              in_source_dir(pg.page_to_copy.prototyped_page.relative_path) == path
            else
              in_source_dir(pg.page_to_copy.relative_path) == path
            end
          next true if found
          next false unless pg.data.layout

          pg_layouts = validated_layouts_for(pg, pg.data.layout)
            .select { _1.path == path }
          next false unless pg_layouts.length.positive?

          pg_layouts.each { layouts_to_reload << _1 }
          true
        end

        layouts_to_reload.each do |layout|
          layouts[layout.label] = Bridgetown::Layout.new(
            self, layout.instance_variable_get(:@base), layout.name
          )
        end
        next unless res || !pages.empty?

        unless pages.empty?
          found_gen_pages = true
          pages.each do |page|
            res = if page.page_to_copy.respond_to?(:prototyped_page)
                    page.page_to_copy.prototyped_page
                  else
                    page.page_to_copy
                  end

            res.prepare_for_fast_refresh! unless res.fast_refresh_order
            page.mark_for_fast_refresh!
          end

          next
        end

        res.prepare_for_fast_refresh!
        next unless res.collection.data?

        res.collection.merge_data_resources.each do |k, v|
          data[k] = v
          signals[k] = v
        end
      end

      marked_resources = resources.select(&:fast_refresh_order).sort_by(&:fast_refresh_order)
      if marked_resources.empty? && !found_gen_pages
        # Darn, a full reload is needed (unless we're on a super-fast track)
        if reload_if_needed
          Bridgetown::Hooks.trigger :site, :pre_reload, self, paths
          Bridgetown::Hooks.clear_reloadable_hooks
          loaders_manager.reload_loaders
          Bridgetown::Hooks.trigger :site, :post_reload, self, paths
          process # bring out the big guns
        end
        return
      end

      Bridgetown::Hooks.trigger :site, :fast_refresh, self

      marked_resources.each { _1.transform!.write }
      number_of_resources = marked_resources.length
      number_of_resources += 1 if found_gen_pages
      Bridgetown.logger.info(
        "⚡️",
        "#{number_of_resources} resource#{"s" if number_of_resources > 1} fast refreshed"
      )

      marked_generated = generated_pages.select(&:fast_refresh_order).sort_by(&:fast_refresh_order)
      unless marked_generated.empty?
        marked_generated.each do |page|
          page.fast_refresh! if page.respond_to?(:fast_refresh!)
          page.transform!.write(dest)
        end
        number_of_pages = marked_generated.length
        Bridgetown.logger.info(
          "⚡️",
          "#{number_of_pages} generated page#{"s" if number_of_pages > 1} fast refreshed"
        )
      end

      FileUtils.touch(in_destination_dir("index.html"))

      Bridgetown::Hooks.trigger :site, :post_write, self
    end

    # Reset all in-memory data and content.
    #
    # @param soft [Boolean] if true, persist some state and do a light refresh of layouts and data
    # @return [void]
    def reset(soft: false) # rubocop:disable Metrics/AbcSize, Metrics/MethodLength
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
      @fast_refresh_ordering = 0 if config.fast_refresh
      @frontend_manifest = nil
      @collections = nil
      @documents = nil
      @docs_to_write = nil
      @liquid_renderer.reset
      tmp_cache.clear

      if soft
        refresh_layouts_and_data
      else
        frontmatter_defaults.reset
        Bridgetown::Cache.clear_if_config_changed config
      end

      Bridgetown::Hooks.trigger :site, (soft ? :after_soft_reset : :after_reset), self
    end

    # Read layouts and merge any new data collection contents into the site data
    def refresh_layouts_and_data
      reader.read_layouts

      collections.data.tap do |coll|
        coll.resources.clear
        coll.read
        coll.merge_data_resources.each do |k, v|
          data[k] = v # refresh site data
        end
      end
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

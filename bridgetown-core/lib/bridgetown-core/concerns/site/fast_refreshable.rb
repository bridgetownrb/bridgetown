# frozen_string_literal: true

class Bridgetown::Site
  module FastRefreshable
    def fast_refresh(paths = [], reload_if_needed: false) # rubocop:todo Metrics
      FileUtils.rm_f(Bridgetown.build_errors_path)

      @fast_refresh_ordering = 0
      full_abort = false
      found_gen_pages = false
      paths.each do |path|
        res = resources.find do |resource|
          resource.id.start_with?("repo://") && in_source_dir(resource.relative_path) == path
        end

        layouts_to_reload = Set.new
        locate_resource_layouts_and_partials_for_fash_refresh(path, layouts_to_reload) unless res

        locate_components_for_fast_refresh(path) unless res

        pages = locate_layouts_and_pages_for_fast_refresh(path, layouts_to_reload)

        layouts_to_reload.each do |layout|
          layouts[layout.label] = Bridgetown::Layout.new(
            self, layout.instance_variable_get(:@base), layout.name
          )
        end
        liquid_renderer.reset unless layouts_to_reload.empty?
        next unless res || !pages.empty?

        unless pages.empty?
          found_gen_pages = true
          mark_original_page_resources_for_fast_refresh(pages)
          next
        end

        res.prepare_for_fast_refresh!.tap { full_abort = true unless _1 }
        next unless res.collection.data?

        res.collection.merge_data_resources.each do |k, v|
          data[k] = v
          signals[k] = v
        end
      end

      marked_resources = resources.select(&:fast_refresh_order).sort_by(&:fast_refresh_order)
      if full_abort || (marked_resources.empty? && !found_gen_pages)
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

      transform_resources_for_fast_refresh(marked_resources, found_gen_pages)
      transform_generated_pages_for_fast_refresh

      FileUtils.touch(in_destination_dir("index.html"))

      Bridgetown::Hooks.trigger :site, :post_write, self
    end

    private

    def locate_resource_layouts_and_partials_for_fash_refresh(path, layouts_to_reload) # rubocop:todo Metrics/AbcSize
      resources.each do |resource|
        next unless resource.data.layout

        res_layouts = validated_layouts_for(resource, resource.data.layout)
          .select { _1.path == path }
        next unless res_layouts.length.positive?

        res_layouts.each { layouts_to_reload << _1 }
        resource.mark_for_fast_refresh!
      end

      tmp_cache.each_key do |key|
        next unless key.delete_prefix("partial-tmpl:") == path

        tmp_cache[key].template = nil
        tmp_cache[key].signal.value += 1
      end
    end

    def locate_components_for_fast_refresh(path)
      comp = Bridgetown::Component.descendants.find do |item|
        item.component_template_path == path || item.source_location == path
      rescue StandardError # rubocop:disable Lint/SuppressedException
      end
      return unless comp

      tmp_cache["comp-signal:#{comp.source_location}"]&.value += 1

      # brute force reload all components for now
      load_path = config.components_load_paths.last
      loader = loaders_manager.loaders[load_path]
      Bridgetown::Hooks.trigger :loader, :pre_reload, loader, load_path
      loader.reload
      loader.eager_load if config.eager_load_paths.include?(load_path)
      Bridgetown::Hooks.trigger :loader, :post_reload, loader, load_path
    end

    def locate_layouts_and_pages_for_fast_refresh(path, layouts_to_reload)
      generated_pages.select do |pg|
        next unless pg.respond_to?(:page_to_copy)

        found = in_source_dir(pg.original_resource.relative_path) == path
        next true if found
        next false unless pg.data.layout

        pg_layouts = validated_layouts_for(pg, pg.data.layout)
          .select { _1.path == path }
        next false unless pg_layouts.length.positive?

        pg_layouts.each { layouts_to_reload << _1 }
        true
      end
    end

    def mark_original_page_resources_for_fast_refresh(pages)
      pages.each do |page|
        res = page.original_resource
        res.prepare_for_fast_refresh! unless res.fast_refresh_order
        page.mark_for_fast_refresh!
      end
    end

    def transform_resources_for_fast_refresh(marked_resources, found_gen_pages)
      marked_resources.each { _1.transform!.write }
      number_of_resources = marked_resources.length
      number_of_resources += 1 if found_gen_pages
      Bridgetown.logger.info(
        "⚡️",
        "#{number_of_resources} resource#{"s" if number_of_resources > 1} fast refreshed"
      )
    end

    def transform_generated_pages_for_fast_refresh
      marked_generated = generated_pages.select(&:fast_refresh_order).sort_by(&:fast_refresh_order)
      return if marked_generated.empty?

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
  end
end

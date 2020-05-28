# frozen_string_literal: true

class LiquidBook < SiteBuilder
  def build
    site.components_load_paths.each do |path|
      load_liquid_components(path)
    end

    layouts = Bridgetown::LayoutReader.new(site).read
    @components.each do |component_filename, component_object|
      doc "#{component_filename}.html" do
        layout :default
        collection :components
        excerpt ""
        component component_object
        title component_object["metadata"]["title"]
        content layouts["component_preview"].content
      end
    end

    liquid_tag "component_previews", :preview_tag
  end

  def load_liquid_components(dir)
    @components ||= {}
    @entry_filter ||= Bridgetown::EntryFilter.new(site)

    return unless File.directory?(dir) && !@entry_filter.symlink?(dir)

    entries = Dir.chdir(dir) do
      Dir["*.{liquid,html}"] + Dir["*"].select { |fn| File.directory?(fn) }
    end

    entries.each do |entry|
      path = site.in_source_dir(dir, entry)
      next if @entry_filter.symlink?(path)

      if File.directory?(path)
        load_liquid_components(path)
      else
        template = ::File.read(path)
        component = LiquidComponent.parse(template)

        unless component.name.nil?
          key = sanitize_filename(File.basename(path, ".*"))
          key = File.join(File.dirname(path.sub(site.in_source_dir("_components") + "/", "")), key)
          @components[key] = component.to_h.deep_stringify_keys.merge({
            "relative_path" => key,
          })
        end
      end
    end
  end

  def preview_tag(_attributes, tag)
    component = tag.context.registers[:page]["component"]
    preview_path = site.in_source_dir("_components", component["relative_path"] + ".preview.html")

    liquid_options = site.config["liquid"]
    info = {
      registers: {
        site: site,
        page: tag.context.registers[:page],
        cached_partials: Bridgetown::Renderer.cached_partials,
      },
      strict_filters: liquid_options["strict_filters"],
      strict_variables: liquid_options["strict_variables"],
    }

    template = site.liquid_renderer.file(preview_path).parse(
      File.read(preview_path)
    )
    template.warnings.each do |e|
      Bridgetown.logger.warn "Liquid Warning:",
                             LiquidRenderer.format_error(e, preview_path)
    end
    template.render!(
      site.site_payload.merge({ page: tag.context.registers[:page] }),
      info
    )
  end

  private

  def sanitize_filename(name)
    name.gsub(%r![^\w\s-]+|(?<=^|\b\s)\s+(?=$|\s?\b)!, "")
      .gsub(%r!\s+!, "_")
  end
end

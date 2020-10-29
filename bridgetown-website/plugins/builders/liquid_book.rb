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
        title component_object["metadata"]["name"]
        content layouts["component_preview"].content
      end
    end

    liquid_tag "component_previews", :preview_tag
  end

  def load_liquid_components(dir, root: true)
    @components ||= {}
    @entry_filter ||= Bridgetown::EntryFilter.new(site)
    @current_root = dir if root

    return unless File.directory?(dir) && !@entry_filter.symlink?(dir)

    entries = Dir.chdir(dir) do
      Dir["*.{liquid,html}"] + Dir["*"].select { |fn| File.directory?(fn) }
    end

    entries.each do |entry|
      path = File.join(dir, entry)
      next if @entry_filter.symlink?(path)

      if File.directory?(path)
        load_liquid_components(path, root: false)
      else
        template = ::File.read(path)
        component = LiquidComponent.parse(template)

        unless component.name.nil?
          key = sanitize_filename(File.basename(path, ".*"))
          key = File.join(Pathname.new(File.dirname(path)).relative_path_from(@current_root), key)
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

    info = {
      registers: {
        site: site,
        page: tag.context.registers[:page],
        cached_partials: Bridgetown::Converters::LiquidTemplates.cached_partials,
      },
      strict_filters: site.config["liquid"]["strict_filters"],
      strict_variables: site.config["liquid"]["strict_variables"],
    }

    template = site.liquid_renderer.file(preview_path).parse(
      File.exist?(preview_path) ? File.read(preview_path) : ""
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

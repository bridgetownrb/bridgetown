# frozen_string_literal: true

class PurgeCSS < SiteBuilder
  def build
    hook :site, :post_write do
      purgecss_file = site.in_root_dir("purgecss.config.js")
      unless File.exist?(purgecss_file)
        config_js = <<~PURGE
          module.exports = {
            content: ['frontend/javascript/*.js','./output/**/*.html'],
            output: "./output/_bridgetown/static/css"
          }
        PURGE
        File.write(purgecss_file, config_js.strip)
      end
      manifest_file = site.in_root_dir(".bridgetown-webpack", "manifest.json")
      if File.exist?(manifest_file)
        manifest = JSON.parse(File.read(manifest_file))
        css_file = manifest["main.css"].split("/").last
        css_path = ["output", "_bridgetown", "static", "css", css_file].join("/")

        Bridgetown.logger.info "PurgeCSS", "Purging #{css_file}"
        oldsize = File.stat(css_path).size / 1000
        system "./node_modules/.bin/purgecss --help"
        system "./node_modules/.bin/purgecss -c purgecss.config.js -css #{css_file}"

        newsize = File.stat(css_path).size / 1000
        if newsize < oldsize
          Bridgetown.logger.info "PurgeCSS", "Done! File size reduced from #{oldsize}kB to #{newsize}kB"
        else
          Bridgetown.logger.info "PurgeCSS", "Done. No apparent change in file size (#{newsize}kB)."
        end
      end
    end
  end
end

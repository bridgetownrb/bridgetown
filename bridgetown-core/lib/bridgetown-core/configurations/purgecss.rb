# frozen_string_literal: true

# rubocop:disable all

say_status :purgecss, "Installing PurgeCSS"

run "yarn add -D purgecss"

create_builder "purgecss.rb" do
  <<~RUBY
    class Builders::Purgecss < SiteBuilder
      def build
        return if config[:watch] # don't run in "watch mode"

        hook :site, :post_write do
          purgecss_file = site.in_root_dir("purgecss.config.js")

          unless File.exist?(purgecss_file)
            config_js = <<~PURGE
              module.exports = {
                content: ['frontend/javascript/*.js','./output/**/*.html'],
                output: "./output/_bridgetown/static"
              }
            PURGE
            File.write(purgecss_file, config_js.strip)
          end

          manifest_file = File.join(site.frontend_bundling_path, "manifest.json")

          if File.exist?(manifest_file)
            manifest = JSON.parse(File.read(manifest_file))

            if Bridgetown::Utils.frontend_bundler_type == :esbuild
              css_file = (manifest["styles/index.css"] || manifest["styles/index.scss"]).split("/").last
              css_path = ["output", "_bridgetown", "static", css_file].join("/")
            else
              css_file = manifest["main.css"].split("/").last
              css_path = ["output", "_bridgetown", "static", "css", css_file].join("/")
            end

            Bridgetown.logger.info "PurgeCSS", "Purging \#{css_file}"
            oldsize = File.stat(css_path).size / 1000
            system "./node_modules/.bin/purgecss -c purgecss.config.js -css \#{css_path}"
            newsize = File.stat(css_path).size / 1000

            if newsize < oldsize
              Bridgetown.logger.info "PurgeCSS",
                                     "Done! File size reduced from \#{oldsize}kB to \#{newsize}kB"
            else
              Bridgetown.logger.info "PurgeCSS",
                                     "Done. No apparent change in file size (\#{newsize}kB)."
            end
          end
        end
      end
    end
  RUBY
end

say_status :purgecss, "All set! Open plugins/builders/purgecss_builder.rb if you'd like to customize the PurgeCSS config."

# rubocop:enable all

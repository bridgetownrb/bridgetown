# frozen_string_literal: true

# rubocop:disable all

unless File.exist?("postcss.config.js")
  error_message = "#{"postcss.config.js".bold} not found. Please configure postcss in your project."

  @logger.error "\nError:".red, "🚨 #{error_message}"
  @logger.info "\nRun #{"bridgetown webpack enable-postcss".bold.blue} to set it up.\n"

  return
end

say_status :tailwind, "Installing Tailwind CSS..."

confirm = ask "This configuration will ovewrite your existing #{"postcss.config.js".bold.white}. Would you like to continue? [Yn]"
return unless confirm.casecmp?("Y")

run "yarn add -D tailwindcss"
run "npx tailwindcss init"

gsub_file "tailwind.config.js", "content: [],", <<~JS.strip
  content: [
      './src/**/*.{html,md,liquid,erb,serb,rb}',
      './frontend/javascript/**/*.js',
    ],
JS

copy_file in_templates_dir("postcss.config.js"), "postcss.config.js", force: true

if File.exist?("frontend/styles/index.css")
  prepend_to_file "frontend/styles/index.css",
                  File.read(in_templates_dir("css_imports.css"))
else
  say "\nPlease add the following lines to your CSS index file:"
  say File.read(in_templates_dir("/css_imports.css"))
end

create_file "frontend/styles/jit-refresh.css", "/* #{Time.now.to_i} */"

insert_into_file "Rakefile",
                  after: %r{  task :(build|dev) do\n} do
  <<-JS
    sh "touch frontend/styles/jit-refresh.css"
  JS
end

if File.exist?(".gitignore")
  append_to_file ".gitignore" do
    <<~FILES

      frontend/styles/jit-refresh.css
    FILES
  end
end

create_builder "tailwind_jit.rb" do
  <<~RUBY
    class Builders::TailwindJit < SiteBuilder
      def build
        hook :site, :pre_reload do |_, paths|
          # Don't trigger refresh if it's a frontend-only change
          next if paths.length == 1 && paths.first.ends_with?("manifest.json")

          # Save out a comment file to trigger Tailwind's JIT
          refresh_file = site.in_root_dir("frontend", "styles", "jit-refresh.css")
          File.write refresh_file, "/* \#{Time.now.to_i} */"
          throw :halt # don't continue the build, wait for watcher rebuild
        end
      end
    end
  RUBY
end

say_status :tailwind, "Tailwind CSS is now configured."

# rubocop:enable all

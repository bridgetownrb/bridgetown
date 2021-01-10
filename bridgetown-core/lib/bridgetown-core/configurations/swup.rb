packages = "swup @swup/body-class-plugin @swup/scroll-plugin @swup/fade-theme"
say_status :swup, "Adding the following yarn packages: #{packages}"
system("yarn add #{packages}")

javascript_import do
  <<~JS
    import Swup from "swup"
    import SwupBodyClassPlugin from "@swup/body-class-plugin"
    import SwupScrollPlugin from "@swup/scroll-plugin"
    import SwupFadeTheme from "@swup/fade-theme"
    const swup = new Swup({
      plugins: [
        new SwupBodyClassPlugin(),
        new SwupScrollPlugin(),
        new SwupFadeTheme(),
      ]
    })
  JS
end

css_index = File.exist?(File.expand_path("frontend/styles/index.scss", destination_root)) ? "frontend/styles/index.scss" : "frontend/styles/index.css"
append_to_file css_index do
  <<~CSS
    .swup-transition-main {
      transition: opacity .2s;
    }
  CSS
end

say_status :swup, "All done! Edit .swup-transition-main in #{css_index} if you wish to adjust the transition animation"
say_status :swup, "Make sure you add id=\"swup\" to the primary container of your HTML layout (perhaps <main>)"
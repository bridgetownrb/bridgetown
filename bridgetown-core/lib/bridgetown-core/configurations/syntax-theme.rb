# frozen_string_literal: true

# TODO: handle if css vs scss

theme = @configuration_option
valid_themes = Rouge::Theme.registry.map { |k, _v| k }.sort

unless valid_themes.include?(theme)
  @logger.error "\nTheme not valid. Please provide a valid theme
                   eg. #{"syntax-theme:github".bold.white}"
  @logger.info "\nValid themes are: \n\n#{valid_themes.join("\n")}\n"

  return
end

say_status :syntax_theme, "Generating syntax theme for #{theme.bold.white}"

create_file "frontend/styles/syntax-theme.css" do
  header_comments = <<~CSS
    /*#{" "}
      Syntax Highlighting Theme for Code Snippets

      https://www.bridgetownrb.com/docs/liquid/tags#stylesheets-for-syntax-highlighting

      Other styles available eg. https://github.com/jwarby/jekyll-pygments-themes

      To use another style, run `bin/bridgetown configure syntax-theme:{theme}` from
      the command line. Eg. `bin/bridgetown configure syntax-theme:github`. To see a
      list of all available styles run `bin/bridgetown configure syntax-theme`.
      Or create your own by editing this file manually!
    */

  CSS

  header_comments +
    Rouge::Theme.find(theme).render(scope: ".highlight")
end

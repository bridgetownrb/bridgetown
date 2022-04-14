# frozen_string_literal: true

# require "rouge"

# TODO: handle if css vs scss

theme = @configuration_option
valid_themes = %w[github valid]

unless valid_themes.include?(theme)
  if defined?(say_status)
    say_status :syntax_theme, "Theme not valid. Please provide a valid theme eg. syntax-theme:github"
    say_status :syntax_theme, "Valid themes are: \n\n#{valid_themes.join("\n")}\n"
  end

  return
end

say_status :syntax_theme, "Generating syntax theme for #{theme}" if defined?(say_status)

create_file "frontend/styles/syntax-test.css" do
  <<~CSS
    /*#{" "}
      Syntax Highlighting for Code Snippets

      https://www.bridgetownrb.com/docs/liquid/tags#stylesheets-for-syntax-highlighting

      Other styles available eg. https://github.com/jwarby/jekyll-pygments-themes

      To use another style, run `bin/bridgetown configure syntax-theme:{theme}` from#{" "}
      the command line. Eg. `bin/bridgetown configure syntax-theme:github`. To see a#{" "}
      list of all available styles run `bin/bridgetown configure syntax-theme`.
      Or create your own by editing this file manually!
    */

    .highlight .c, .highlight .ch, .highlight .cd, .highlight .cpf {
      color: #5e5d83;
      font-style: italic;
    }

  CSS
end

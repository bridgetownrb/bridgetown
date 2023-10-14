class RubyHtmlText < Bridgetown::Component
  include Bridgetown::HTMLinRuby

  def template
    html->{ <<-HTML
      <p>This is #{text->{"<b>escaped!</b>"}}</p>
      #{html markdownify { "_yipee_" }, -> { sub("yipee", "yay") } }
    HTML
    }
  end
end

class RubyHtmlText < Bridgetown::Component
  include Bridgetown::HTMLinRuby

  def template
    # blub = ->(input, str, replace_str) { input.sub(str, replace_str) }

    macro :flub do |input, str, replace_str|
      input.sub str, replace_str
    end

    html->{ <<-HTML
      <p>This is #{text->{"<b>escaped!</b>"}}</p>
      #{html->{markdownify { "_yipee_" }}.pipe { flub("yipee", "yay") }}
    HTML
    }
  end
end

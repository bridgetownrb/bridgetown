class RubyHtmlText < Bridgetown::Component
  def template
    # blub = ->(input, str, replace_str) { input.sub(str, replace_str) }

    macro :flub do |input, str, replace_str|
      input.sub str, replace_str
    end

    html -> {
      <<~HTML
        <p>This is #{text -> { "<b>escaped!</b>" }}</p>
        #{text(-> { markdownify { "_yipee_" } }.pipe { flub("yipee", "yay") | html_safe })}
      HTML
    }
  end
end

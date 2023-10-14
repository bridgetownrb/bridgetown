###ruby
front_matter do
  layout :default
  title "I am Ruby. Here me roar!"
  include_markdown true
end
###

render html->{ <<-HTML
  <p>Hello #{text "<u>woRld</u>", ->{ downcase | upcase }}</p>
  #{ render "a_partial", abc: 123 }
  #{ render "an_erb_partial", abc: 456 }
  #{ html-> do
    if data.title.include?("Ruby")
      render RubyHtmlText.new
    else
      nil
    end
  end }
  HTML
}

if data.include_markdown
  render do
    str = "interesting"

    markdownify <<~MARKDOWN

      > Well, _this_ is quite #{str}! =)

    MARKDOWN
  end
end

render html->{ <<-HTML
  <ul>
  #{html_map 3.times, ->(i) { <<-HTML
    <li>#{text->{i}}</li>
  HTML
  }}
  </ul>
HTML
}

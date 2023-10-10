###ruby
front_matter do
  layout :default
  title "I am Ruby. Here me roar!"
  include_markdown true
end
###

render html: <<-HTML
  <p>Hello #{text "<p>world</p>"}</p>
  #{ render "a_partial", abc: 123 }
  #{ render "an_erb_partial", abc: 456 }
HTML

if data.include_markdown
  render do
    markdownify <<~MARKDOWN

      > Well, _this_ is quite interesting! =)

    MARKDOWN
  end
end

render html: <<-HTML
  <ul>
  #{3.times.html_map do |i| <<-HTML
    <li>#{text i}</li>
  HTML
  end}
  </ul>
HTML

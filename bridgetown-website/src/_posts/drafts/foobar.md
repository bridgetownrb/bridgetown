---
title: Foo Bar!
some_value: |
  <RUBY>
  def foo
    a = "a"

    Bridgetown.logger.info "Loading " + MySite::Provider.thing

    page.data['title'] = "HAHAHA"
    page.content += "\nTITLE: **{{ page.title }}**\n"

    page.data['fancy_posts_length'] = site.posts.docs.length

    a + "b"
  end

  sleep 1

  dirs = Dir.entries("/Users")

  "#{foo} One #{2 + 2} three. \n\n#{dirs}\n\n" + page.data['title']

some_other_value: Wee!
---

I am a draft!

# of Posts: {{ page.fancy_posts_length }}

{{ page.some_other_value }}

Value:

{{ page.some_value }}

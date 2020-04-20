---
title: Foo Bar!!
monster_query: Bar 
return_items: 3
ruby_hash: !ruby/string:Rb |
  require "faraday"

  cache = Bridgetown::Cache.new("foobar")

  json = cache.getset(page.data["monster_query"]) do
    p "There be monsters!"
    endpoint = "https://opdb.org/api/search/typeahead"
    resp = Faraday.get(endpoint, {q: page.data["monster_query"]})
    JSON.parse(resp.body)
  end

  {:one => "twooooo",
    three: "four", "five" => "six",
    monsters: json[0...page.data["return_items"]]
  }
some_value: !ruby/string:Rb |
  def foo
    a = "a"

    Bridgetown.logger.info "Loading " + MySite::Provider.thing

    page.data['title'] = "HAHAHA"
    page.content += "\nTITLE: **{{ page.title }}**\n"

    page.data['fancy_posts_length'] = site.posts.docs.length

    a + "b"
  end

  dirs = Dir.entries("/Users")

  "#{foo} One #{2 + 2} three. \n\n#{dirs}\n\n" + page.data['title']

some_other_value: Wee!
---

I am a draft!

# of Posts: {{ page.fancy_posts_length }}

{{ page.some_other_value }}

Value:

{{ page.some_value }}

----

<pre>
{{ page.ruby_hash.one }}, {{ page.ruby_hash.three }}, {{ page.ruby_hash.five }}

Monsters!

{% for monster in page.ruby_hash.monsters %}
- {{ monster.name }} — ({{ monster.supplementary }})
{% endfor %}
</pre>

----


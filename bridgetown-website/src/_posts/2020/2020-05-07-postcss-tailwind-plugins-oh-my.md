---
title: PostCSS, Tailwind, Plugins…Oh My!
subtitle: For you diehard fans of Tailwind CSS out there, Andrew Mason has got you covered. Also, we now have a GitHub-sourced Plugins directory!
author: jared
category: news
---

Personally, [I'm a Bulma man myself](https://bulma.io), but I understand there are a ton of you out there who love [Tailwind CSS](https://tailwindcss.com) and won't give it up until they pry it out of your cold, dead hands.

So I'm pleased as Ruby-colored punch to [highlight this breezy tutorial by Andrew Mason][andrewm-blog] all about how you can quickly and easily set up a new Bridgetown website with Tailwind CSS and PostCSS.

From the [article][andrewm-blog]:
									 
> If you have had Ruby/Rails/Jekyll experience, you should feel right at home with Bridgetown. Bridgetown also removes the barrier to entry for integrating webpack and all the goodies the JavaScript community has to offer.

[andrewm-blog]: https://andrewm.codes/blog/build-and-deploy-a-static-site-with-ruby-bridgetown-tailwindcss-and-netlify/

### Plugins Are Coming 😲

A major theme of the next Bridgetown release codenamed "Hazelwood" is make everything about plugins better—whether it's writing plugins, publishing gem-based plugins, or utilizing plugins effectively in your Bridgetown websites.

To that end, [we've just put up a new Plugins directory](/plugins/) here on the site. What's rather cool about the implementation is that we're simply sourcing all the data directly from GitHub. So all you need to do is add the `bridgetown-plugin` topic to your plugin repo, and it'll get picked up here on the site as soon as its rebuilt. In case you're wondering, we used the new [Ruby Front Matter](/docs/front-matter/#ruby-front-matter){:data-no-swup="true"} feature to write the code to pull all the data off GitHub. Here's what it looks like:

```yaml
# src/plugins.html

layout: default
title: Jazz Your Site Up with Plugins
plugins: !ruby/string:Rb |
  endpoint = "https://api.github.com/search/repositories?q=topic:bridgetown-plugin"

  conn = Faraday.new(
    url: endpoint,
    headers: {"Accept" => "application/vnd.github.v3+json"}
  )
  if ENV["BRIDGETOWN_GITHUB_TOKEN"]
    username, token = ENV["BRIDGETOWN_GITHUB_TOKEN"].split(":")
    conn.basic_auth(username, token)
  end
  items = JSON.parse(conn.get.body)["items"]

  items.each do |item|
    begin
      gem_url = "https://raw.githubusercontent.com/#{item["full_name"]}/master/lib/#{item["name"]}/version.rb"
      result = Faraday.get(gem_url).body
      item["gem_version"] = result.match(/VERSION = "(.*?)"/)[1]
    rescue
    end
  end

  items
```

And then down in the page we can use simple Liquid template syntax to loop through the plugins and output all relevant information. A simplified example:

{% raw %}
```liquid
{% for plugin in page.plugins %}
  <a href="{{ plugin.html_url }}">
    <h2>{{ plugin.name }}
      {% if plugin.gem_version %}
        <span class="tag">v{{ plugin.gem_version }}</span>
      {% endif %}
    </h2>
  </a>

  <div>{{ plugin.description }}</div>

  <div class="author">
    <img src="{{ plugin.owner.avatar_url }}" alt="{{ plugin.owner.login }}" class="avatar" />
    <a href="{{ plugin.owner.html_url }}">{{ plugin.owner.login }}</a>
  </div>
{% endfor %}
```
{% endraw %}

So take a peek at the [new Plugins directory](/plugins/) and think of what you'd like to see there in the future and then [let us know!](https://github.com/bridgetownrb/bridgetown/issues/new?assignees=&labels=feature&template=feature_request.md&title=feat%3A+)

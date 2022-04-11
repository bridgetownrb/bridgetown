---
title: "A Bridge to the Future: What’s New in Bridgetown 0.14 “Hazelwood”"
subtitle: The biggest public release of Bridgetown since its inception, featuring the brand-new Unified Plugins API, Active Support, and a whole lot more.
author: jared
category: release
---

Bridgetown 0.14 "Hazelwood" is here! 🎉 And it's the biggest public release of Bridgetown since its inception.

In the first of many clean breaks with its Jekyll-inherited past, Hazelwood introduces the brand-new [Unified Plugins API](/docs/plugins) which makes the process of extending Bridgetown sites dramatically easier.

Previously if you wanted to add a Liquid tag (aka "shortcode") to your site, plus a Liquid filter, as well as generate some new posts based on input data, you'd have to use three, completely unrelated, low-level APIs while writing a custom plugin. Furthermore, every time you changed the code in your plugin, you'd have to _manually restart the server_ to see the effects of your change.

Today, everything changes. 😎

### Introducing Builders

In Bridgetown 0.14, any Ruby files in your `plugins` folder are hot-reloaded every time you update one, and the new way you write plugins is using Builders.

Remember the previous challenge of coding Liquid tags, filters, and dynamic content in a straightforward, easy-to-remember fashion? Feast your eyes upon this:

```ruby
# plugins/builders/welcome_to_hazelwood.rb
class WelcomeToHazelwood < SiteBuilder
  def build
    liquid_tag "welcome" do |attributes|
      "Welcome to Hazelwood, #{attributes}!"
    end
    liquid_filter "party_time", :party_time

    add_new_posts
  end

  def party_time(input)
    "#{input} 🥳"
  end

  def add_new_posts
    get "https://domain.com/posts.json" do |data|
      data.each do |post|
        doc "#{post[:slug]}.md" do
          front_matter post
          categories post[:taxonomy][:category].map { |category| category[:slug] }
          date Bridgetown::Utils.parse_date(post[:date])
          content post[:body]
        end
      end
    end
  end
end
```

In this example, a new [Liquid tag](/docs/plugins/tags) "welcome" is created which can then be used anywhere on the site:

{% raw %}`{% welcome Friends %}`{% endraw %}

Likewise a [Liquid filter](/docs/plugins/filters) "party_time":

{% raw %}`{{ "Party time!" | party_time }}`{% endraw %}

Plus an external JSON resource is downloaded and converted to new blog posts via the [Document Builder DSL](/docs/plugins/external-apis). This is clearly an awesome way to construct new pages for your site based on data in your repo or elsewhere on the web.

With the [new Builder API](/docs/plugins) in Hazelwood, you can write plugins to do pretty much anything you can imagine during a site build process. But wait, there's more!

### Source Manifests for Gem-based Plugins

For plugins that get installed as gems via Bundler, not only can they too use the Builder API in all of the same ways as local plugins, but they can now supply additional content such as layouts, pages, static files, and Liquid components from folders in the gem using [source manifests](/docs/plugins/source-manifests).

Registering a new source manifest couldn't be easier:

```ruby
# bridgetown-sample-plugin/lib/sample-plugin.rb
require "bridgetown"
require "sample-plugin/builder"

Bridgetown::PluginManager.new_source_manifest(
  origin: SamplePlugin,
  components: File.expand_path("../components", __dir__),
  content: File.expand_path("../content", __dir__),
  layouts: File.expand_path("../layouts", __dir__)
)
```

Now all of the extra content and templates provided by `SamplePlugin` will be made available to the site which adds this gem. In addition, site owners can run `bridgetown plugins list` to [display information about loaded source manifests and other plugin features](/docs/commands/plugins)—or even copy content out of plugins directly into the site repo using `bridgetown plugins cd`.

Wait a minute…does this mean…could it be…whoa, can you now create…**themes?!?!**

Well, we're not officially announcing that today, but stay tuned. 😁 The short answer is: **Themes Are Coming.** The long answer is we want to get this right out-of-the-gate, and there's a lot of DX (Developer Experience) logistics we'd like to address properly before loudly tooting the _Bridgetown Themes horn_.

But in the meantime if you have bits of reusable "stuff" you'd like to package into a gem and provide to Bridgetown sites you or others are building, now is the time to go for it!

### What Else is New in Hazelwood

Besides the [Unified Plugins API](/docs/plugins) with builders, source manifests, and local plugin hot-reloading, we've begun working on a couple of major initiatives around the internals of Bridgetown to modernize them and make them feel more, well, Ruby-ish.

First of all, starting with 0.14 we're now shipping [Active Support](https://guides.rubyonrails.org/active_support_core_extensions.html) with Bridgetown. Our first usage is to employ `HashWithIndifferentAccess` for all data hashes for site config, data files, document front matter, and so forth.

So `site.data[:some_json][:values][3][:nice]` and `site.data["some_json"]["values"][3]["nice"]` work interchangeably, as do `post.data[:title]` and `post.data["title"]`. Yippee!

Our next goal is to layer in all the convenience methods we know and love from Rails, like `present?` and `truncate` and `to_sentence`—as well as the awesome extensions to `Date` and `Time`. This will make code easier and more fun to write internally, as well as ensure a higher baseline of functionality for gem-based plugins.

Finally, the other major step forward in Hazelwood is we're starting to break up the "god" objects—those pieces of the software which are defined in lengthy code files which are hard to parse and decipher. This time around we tackled [`Bridgetown::Site`](https://github.com/bridgetownrb/bridgetown/blob/main/bridgetown-core/lib/bridgetown-core/site.rb) and broke it up in multiple Concerns which logically group site data and operations by the role they play in the overall build process. We'll continue to iterate on this and possibly move some code out of concerns and into separate objects eventually, but we feel like this is already a big win. Next we'll be tackling `Bridgetown::Document`!

**Bonus tip:** if you've been seeing strange characters in your terminal after `ctrl-c`ing from a `yarn start` session, we've [updated the default `start.js`](https://github.com/bridgetownrb/bridgetown/blob/main/bridgetown-core/lib/site_template/start.js) to resolve that issue. Copy that updated file into your repo to fix it for your site.

## Conclusion

Bridgetown 0.14 "Hazelwood" is an exciting release, not merely because of what it enables website designers and developers to do today, but because of the impact it will have on future releases of Bridgetown.

[Give Bridgetown a spin](/docs) and [let us know what you think](/community)!

Also check out [our new Core Concepts guide](/docs/core-concepts) to learn more about the fundamentals of Bridgetown.

And stay tuned for further tutorials and community plugin news in the weeks ahead!

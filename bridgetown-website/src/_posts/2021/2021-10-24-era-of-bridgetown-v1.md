---
title: The Era of Bridgetown v1 Has Begun. Welcome to the “Pearl”
subtitle: |
  Join our fundraising campaign so we can keep adding nifty goodies to Bridgetown and help make your websites awesome.
author: jared
category: release
---

Named after the famed [Pearl District](https://explorethepearl.com) on Portland’s west side, I’m pleased to announce the first public alpha release of **Bridgetown 1.0** (technically 1.0.0.alpha5). v1 is _chock full_ of major advancements for the platform. [Read the “edge” documentation now available here](https://edge.bridgetownrb.com)—or skip down below for upgrade notes from v0.x.

But before we get to all that, a **second announcement**!

As you may know, Bridgetown is entirely funded by “viewers like you,” and we’ve taken on (and in some respects already executed!) [an ambitious roadmap](https://www.bridgetownrb.com/future/roadmap-to-1.0/) heading into 2022. In other words, **we need your help** to get v1 finalized, polished, and ready for production—as well as further all the work which goes into writing documentation, creating tutorials, attending to design & branding, and generally shepherding the ecosystem.

Therefore, **[we’ve launched a dedicated fundraising site for Bridgetown](https://fundraising.bridgetownrb.com).** We hope you join the campaign to push v1 over the finish line, and please help us spread the word so other interested Rubyists and web developers may contribute as well.

Now without further ado, onto the latest version of Bridgetown codenamed “Pearl”. I’ve talked about some of the changes therein previously, but let’s recap what’s new in this release!

## Ruby-Centric Tooling (Rake, Rack, Puma, & Roda)

In prior versions of Bridgetown, we had leaned on some Node-based tooling to provide features such as CLI scripts (via Yarn/package.json), executing multiple processes simultaneously (Bridgetown’s dev server + Webpack), and live-reloading.

In 1.0, we’ve replaced _nearly all_ of those Node-based tools. Yarn is still utilized to kick off frontend bundling, but everything else has been brought in-house. By simply running `bin/bridgtown start` (`bin/bridgetown s` for short), you get a dev server, build watcher, and frontend bundler (Webpack for now, but alternatively esbuild in the near future) all booted at once along with live-reload functionality. If you’ve ever used Foreman or Overmind before to run multiple processes in parallel, Bridgetown does that now **without any additional dependencies**.
  
Bridgetown’s new dev server is based on the battle-hardened one-two punch of [Rack](https://github.com/rack/rack) + [Puma](https://puma.io) (our previous WEBrick-based server is now deprecated). This new server is fully capable of serving (heh, heh) as a production server as well, should the need arise. On top of Puma we layered on [Roda](http://roda.jeremyevans.net), a refreshingly fast & lightweight web framework created by Jeremy Evans. On a basic level, it handles serving of all statically-built site files. But that’s just the beginning as you’ll soon discover.

By moving to a Rack-based stack, this means _every Bridgetown site is potentially a Rails app, or Sinatra, or Roda itself, or…_. Because Rack can mount multiple “apps” within a single server process, you can run Bridgetown alongside your favorite backend/fullstack Ruby app framework. Yet with Roda on the scene, we just couldn’t help ourselves…

## Bridgetown SSR, Roda API, and File-based Dynamic Routes

Server-Side Rendering, known as SSR, has made its peace with SSG (Static Site Generation), and we are increasingly seeing an SSG/SSR “hybrid” architecture emerge in tooling throughout the web dev industry.

Bridgetown 1.0 takes advantage of this evolving paradigm by providing a streamlined path for booting a site up in-memory. This means you can write a server-side API to render content whenever it is requested. While this API could be implemented with any Ruby framework, you might very well want to take advantage of our native Roda integration because **it’s just that easy to add a dynamic API route**.

For example, I’ve been building a new site which downloads content from the Prismic headless CMS. I need a dynamic route which can render a preview of any content as requested by a content editor working within Prismic. Here’s an example (slightly simplified) of what that looks like:

```ruby
# ./server/routes/preview.rb

class Routes::Preview < Bridgetown::Rack::Routes
  route do |r|
    r.on "preview" do
      # Our special rendering pathway to preview a page
      # route: /preview/:custom_type/:id
      r.is String, String do |custom_type, id|
        bridgetown_site.config.prismic_preview_token = r.cookies[Prismic::PREVIEW_COOKIE]

        Bridgetown::Model::Base
          .find("prismic://#{custom_type}/#{id}")
          .render_as_resource
          .output
      end
    end
  end
end
```

This route handles any `/preview/:custom_type/:id` URLs which are accessed via Prismic. It pulls in a preview token cookie (previously established by a different route), finds a content item via a Prismic Origin ID (an aspect of the Prismic Bridgetown plugin I’m developing), and renders that item’s **resource** which is then output as HTML. Needless to say, _this was simply an impossible task_ prior to Bridgetown 1.0.

SSR is great for generating preview content on-the-fly, but you can use it for any number of instances where it’s not feasible to pre-build your content. In addition, you can use SSR to “refresh” stale content…for example, you could pre-build all your product pages statically, but then request a newer version of the page (or better yet, just a component of it) whenever the static page is viewed which would then contain the up-to-date pricing (perhaps coming from a PostgreSQL database or some other external data source). And if you cache _that_ data using Redis in, say, 10-minute increments, you’ve just built yourself an extremely performant e-commerce solution. This is only a single example!

**But wait, there’s more!** We now ship a new gem you can opt-into (as part of the Bridgetown monorepo) called `bridgetown-routes`. Within minutes of installing it, you gain the ability to write file-based dynamic routes with view templates right inside your source folder!

Here’s a route I’ve added, available at `/items`, which shows a list of item links:

```eruby
---<%
# ./src/_routes/items/index.erb

# route: /items
r.get do
  render_with data: {
    layout: :page,
    title: "Dynamic Items",
    items: [
      { number: 1, slug: "123-abc" },
      { number: 2, slug: "456-def" },
      { number: 3, slug: "789-xyz" },
    ]
  }
end
%>---

<ul>
  <% resource.data.items.each do |item| %>
    <li><a href="/items/<%= item[:slug] %>">Item #<%= item[:number] %></a></li>
  <% end %>
</ul>
```

_Wait a minute_, I hear you saying. _I thought Bridgetown was just a static site generator. Are you really telling me you can now build server-side apps with it?_

**Yup.**

Since all the data in the above example is created and rendered by the server in real-time, there’s no way to know ahead of time which routes should be accessible via `/items/:slug`. That’s why `bridgetown-routes` supports routing placeholders at the filesystem level! Let’s go ahead and define our item-specific route:

```eruby
---<%
# ./src/_routes/items/[slug].erb

# route: /items/:slug
r.get do
  item_id, *item_sku = r.params[:slug].split("-")
  item_sku = item_sku.join("-")

  render_with data: {
    layout: :page,
    title: "Item Page",
    item_id: item_id,
    item_sku: item_sku
  }
end
%>---

<p><strong>Item ID:</strong> <%= resource.data.item_id %></p>

<p><strong>Item SKU:</strong> <%= resource.data.item_sku %></p>

```

This is a contrived example of course, but you can easily imagine loading a specific item from a data source based on the incoming parameter(s) and providing that item data to the view, all within a single file.

You can even use placeholders in folder names! A route saved to `src/_routes/books/[id]/chapter/[chapter_id].erb` would match to something like `/books/234259/chapter/5` and let you access `r.params[:id]` and `r.params[:chapter_id]`. Pretty nifty.

Testing is straightforward as well. Simply place `.test.rb` files alongside your routes, and you’ll be able to use Capybara to write **fast** integration tests including interactions requiring Javascript (assuming Cupite is also installed).

Rest assured, a **full setup guide & tutorial** for all this stuff is on its way. ([Want to get it sooner?](https://fundraising.bridgetownrb.com) 😉)

## The DREAMstack Has Arrived

The bottom line it this: Bridgetown has evolved into more than “just” a static site generator and can now be considered a fullstack web framework, thanks to the incredible building blocks of Rack, Puma, Roda, and what’s come before in Bridgetown. You’re certainly under no obligation to use _any_ of this new dynamic routing functionality, but it’s there _if and when_ you need it. This is the final realization of what I have lovingly referred to as the “DREAMstatck” — **D**elightful **R**uby **E**xpressing **A**PIs **A**nd **M**arkup.

In terms of a deployment strategy, we highly recommend [Render](https://render.com). With a simple `render.yaml` file, you can deploy both a static site and a dynamic server from a single codebase (monorepo) which are then both refreshed in tandem any time you commit and push to GitHub. We’ll post an entire article all about this deployment strategy in the coming days. And if you don’t expect a whole lot of traffic, you can even jettison the static site entirely and only deploy the server, letting Puma handle all incoming traffic. It’s not as crazy as you might think because any static-only content is _always_ pre-built and served as static assets (even if Bridgetown SSR is enabled) whenever you run `bin/bridgetown start`. The only downside would be it’s not cached on a global CDN as a fully-fledged static site on Render would be.

## The Migration to Resources is Now Complete

The other major shift in Bridgetown 1.0 is the removal of the “legacy” content engine in favor of the new “resource” content engine. By consolidating all disparate types of content—datafiles, posts, pages, and custom collection entries—down to one singular and powerful concept (the resource), a vast number of limitations, confusing discrepancies, and outright bugs have been eliminated, and we’re well on our way to providing next-gen content modeling and authoring capabilities rivaling the world’s finest SSGs.

I’ve been using resources exclusively on all Bridgetown site projects for a while now, and it’s been a blast. I simply can’t wait to see what Ruby web developers near and far create using this new technology. [Resource documentation is now available on our edge site](https://edge.bridgetownrb.com/docs/resources). (If you aren't in a position to migrate your codebase to use resources just yet, no worries. We'll continue to update the 0.2x version of Bridgetown with major bugfixes/security patches until well after 1.0's official release.)

## More Awesomeness to Come (I18n, esbuild, ERB/Serbea starter kits, SSR enhancements…)

Bridgetown 1.0 “Pearl” is already the most action-packed release since the initial launch of the framework, but in many ways we’re just getting started. From full internationalization (I18n) features to blazing-fast frontend bundling via esbuild, from new supercharged starter kits to numerous SSR and Roda API improvements, we expect subsequent releases past 1.0 to continue the trend of making rapid progress for maximum DX (Developer Experience).

We encourage you to [try Bridgetown 1.0 alpha today](https://edge.bridgetownrb.com), and then jump into our [Discord chat](https://discord.gg/4E6hktQGz4) to let us know what you think. Your feedback and ideas are invaluable in shaping the future of Bridgetown and helping make it the best site generator for Rubyists everywhere.

## Upgrading from v0.2x

{%@ Note type: :warning do %}
There's now an official up-to-date [upgrade guide available here](/docs/installation/upgrade).
{% end %}

First, you’ll need to specify the new version in your Gemfile:

```ruby
gem "bridgetown", "~> 1.0.0.alpha11"
```

You’ll also need to add Puma to your Gemfile:

```ruby
gem "puma", "~> 5.2"
```

Then run `bundle install`. (You’ll also want to upgrade to the latest version of any extra plugins you may have added, such as the feed and seo plugins.)

Next we suggest you run `bundle binstubs bridgetown-core` so you have access to `bin/bridgetown`, as this is now the canonical way of accessing the Bridgetown CLI within your project.

You will need to add a few additional files to your project, so we suggest using `bridgetown new` to create a separate project, then copy these files over:

* `config.ru`
* `Rakefile`
* `config/puma.rb`
* `server/*`

Finally, you can remove `start.js` and `sync.js` and well as any scripts in `package.json` besides `webpack-build` and `webpack-dev` (and you can also remove the `browser-sync` and `concurrently` dev dependencies in `package.json`).

Going forward, if you need to customize any aspect of Bridgetown’s build scripts or add your own, you can alter your `Rakefile` and utilize Bridgetown’s automatic Rake task support.

**Note:** starting with alpha8, your plugins folder will be loaded via Zeitwerk by default. This means you'll need to namespace your Ruby files using certain conventions or reconfigure the loader settings. [Read the documentation here](https://edge.bridgetownrb.com/docs/plugins#zeitwerk-and-autoloading){:data-no-swup="true"}.

The other major change you’ll need to work on in your project is switching your plugins/templates to use resources. There’s a fair degree of [documentation on our edge site regarding resources](https://edge.bridgetownrb.com/docs/resources). In addition, if you used the Document Builder API in the past, you’ll need to upgrade to the [Resource Builder API](https://edge.bridgetownrb.com/docs/plugins/external-apis).

We’ve added an “upgrade-help” channel in our [Discord chat](https://discord.gg/4E6hktQGz4) so if you get totally suck, the community can give you a leg up! (Access to the problematic repo in question is almost always a given in order to troubleshoot, so if your code needs to remain private, please create a failing example we can access on GitHub.)

---- 

**You’ve made it this far? Wow!** Thanks so much for your interest in the future of Bridgetown—and if you haven’t already, [please join our fundraising campaign](https://fundraising.bridgetownrb.com) so we can keep adding nifty goodies to Bridgetown and help make your websites awesome.
---
title: Dynamic Routes & SSR
order: 250
top_section: Experimental
category: routes
---


{%@ Note type: "warning" do %}
#### This is just the beginning…

While Bridgetown's fullstack framework features (aka SSR, file-based routing, and API endpoints) are already being used in production settings, this functionality is still considered "experimental" and subject to further refinement in Bridgetown 1.1 and beyond. Fully-fledged documentation is in the works and ongoing. 
{% end %}

Bridgetown 1.0 comes with a production-ready web server based on the battle-hardened one-two punch of [Rack](https://github.com/rack/rack) + [Puma](https://puma.io). On top of Puma we've layered on [Roda](http://roda.jeremyevans.net), a refreshingly fast & lightweight web routing toolkit created by Jeremy Evans. On a basic level, it handles serving of all statically-built site files you access when you run `bin/bridgetown start`.

Because Bridgetown uses a Rack-based stack, this means you can potentially add on API endpoints served by a secondary Rails app, or Sinatra, or of course, Roda. In other words, because Rack is fully capable of mounting multiple “apps” within a single server process, you can run Bridgetown alongside your favorite backend/fullstack Ruby app framework. Naturally, we recommend starting out with the framework we've built with Roda as you'll learn more about shortly.

## Bridgetown SSR via Roda

Server-Side Rendering, known as SSR, has made its peace with SSG (Static Site Generation), and we are increasingly seeing an SSG/SSR “hybrid” architecture emerge in tooling throughout the web dev industry.

Bridgetown 1.0 takes advantage of this evolving paradigm by providing a streamlined path for booting a site up in-memory. This means you can write a server-side API to render content whenever it is requested. Here’s an example of what that looks like:

```ruby
# ./server/routes/preview.rb

class Routes::Preview < Bridgetown::Rack::Routes
  route do |r|
    r.on "preview" do
      # Our special rendering pathway to preview a page
      # route: /preview/:collection/:path
      r.get String, String do |collection, path|
        item = Bridgetown::Model::Base.find("repo://#{collection}/#{path}")

        unless item.content.present?
          response.status = 404
          next Bridgetown::Model::Base.find("repo://pages/_pages/404.html")
            .render_as_resource
            .output
        end

        item
          .render_as_resource
          .output
      end
    end
  end
end
```

This route handles any `/preview/:collection/:path` URLs which are accessed just like any other statically-generated resource. It will find a content item via a repo origin ID and render that item’s **resource** which is then output as HTML. Needless to say, _this was simply an impossible task_ prior to Bridgetown 1.0. For example: `/preview/posts/_posts%2F2022-01-10-hello-world.md` would SSR the Markdown content located in `src/_posts/2022-01-10-hello-world.md`.

SSR is great for generating preview content on-the-fly, but you can use it for any number of instances where it’s not feasible to pre-build your content. In addition, you can use SSR to “refresh” stale content…for example, you could pre-build all your product pages statically, but then request a newer version of the page (or better yet, just a component of it) whenever the static page is viewed which would then contain the up-to-date pricing (perhaps coming from a PostgreSQL database or some other external data source). And if you cache _that_ data using Redis in, say, 10-minute increments, you’ve just built yourself an extremely performant e-commerce solution. This is only a single example!

In order to opt-into SSR support, modify your `server/roda_app.rb` file so it loads the SSR plugin:

```ruby
class RodaApp < Bridgetown::Rack::Roda
  plugin :bridgetown_ssr
  
  # etc.
end
```

### Priority Flag

You can configure a `Routes` class with a specific `priority` flag. This flag determines what order the router is loaded in relative to other routers.

The default priority is `:normal`. Valid values are:

<code>:lowest</code>, <code>:low</code>, <code>:normal</code>, <code>:high</code>, and <code>:highest</code>.
Highest priority plugins are run first, lowest priority are run last.

Examples of specifying this flag:

```ruby
class Routes::InitialSetup < Bridgetown::Rack::Routes
  priority :highest

  route do |r|
    r.session[:adding_this] ||= "value"
  end
end

class Routes::LaterOn < Bridgetown::Rack::Routes
  route do |r|
    r.get "later" do
      { session_value: r.session[:adding_this] } # :session_value => "value"
    end
  end
end
```

## File-based Dynamic Routes

**But wait, there’s more!** We now ship a new gem you can opt-into (as part of the Bridgetown monorepo) called `bridgetown-routes`. Within minutes of installing it, you gain the ability to write file-based dynamic routes with view templates right inside your source folder!

Here’s an example of a route saved to `src/_routes/items/index.erb`. It provides the `/items` URL which shows a list of item links:

```eruby
---<%
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

Since all the data in the above example is created and rendered by the server in real-time, there’s no way to know ahead of time which routes should be accessible via `/items/:slug`. That’s why `bridgetown-routes` supports routing placeholders at the filesystem level! Let’s go ahead and define our item-specific route in `src/_routes/items/[slug].erb`:

```eruby
---<%
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

Testing is straightforward as well. Simply place `.test.rb` files alongside your routes, and you’ll be able to use Capybara to write **fast** integration tests including interactions requiring Javascript (assuming Cupite is also installed). (_docs coming soon_)

To opt-into the `bridgetown-routes` gem, make sure it's enabled in your `Gemfile`:

```ruby
gem "bridgetown-routes", group: :bridgetown_plugins
```

and added in as a Roda plugin below the SSR plugin:

```ruby
class RodaApp < Bridgetown::Rack::Roda
  plugin :bridgetown_ssr
  plugin :bridgetown_routes

  # etc.
end
```

## URL Helpers

You can use the `relative_url` and `absolute_url` helpers within your Roda code any time you need to reference a particular URL, to ensure any base path or locale prefix gets added automatically. It also will work with any object which responds to a method like `relative_url` or `url`. For example:

```rb
r.redirect relative_url("/path/to/page")

r.redirect relative_url(obj)
```

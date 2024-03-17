---
title: Server-Rendered Routes
order: 250
top_section: Architecture
category: routes
---

Bridgetown comes with a production-ready web server based on the battle-hardened one-two punch of [Rack](https://github.com/rack/rack) + [Puma](https://puma.io). On top of Puma we've layered on [Roda](http://roda.jeremyevans.net), a refreshingly fast & lightweight web routing toolkit created by Jeremy Evans. On a basic level, it handles serving of all statically-built site files you access when you run `bin/bridgetown start`.

Bridgetown lets you create your own Roda-based API routes in the `server/routes` folder. An example ships in each new Bridgetown project for you to examine (`server/routes/hello.rb.sample`). These routes provide the standard features you may be accustomed to if you've used Roda standalone.

However, to take full advantage of all the Bridgetown has to offer, we recommend you load up our SSR and Dynamic Routes plugins. Simply add to your configuration in `config/initializers.rb`:

```rb
init :ssr
init :"bridgetown-routes"

# …or you can just init the routes, which will init :ssr automatically:

init :"bridgetown-routes"
```

{%@ Note do %}
For more information on setup, read our documentation on [configuring Roda](/docs/configuration/initializers#adding-roda-blocks) and on [configuring Puma](/docs/configuration/puma).
{% end %}

{{ toc }}

## Bridgetown SSR via Roda

Server-Side Rendering, known as SSR, has made its peace with SSG (Static Site Generation), and we are increasingly seeing an SSG/SSR “hybrid” architecture emerge in tooling throughout the web dev industry.

Bridgetown takes advantage of this evolving paradigm by providing a streamlined path for booting a site up in-memory. This means you can write a server-side API to render content whenever it is requested. Here’s an example of what that looks like:

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
        end

        item
      end
    end
  end
end
```

This route handles any `/preview/:collection/:path` URLs which are accessed just like any other statically-generated resource. It will find a content item via a repo origin ID and render that item as HTML. For example: `/preview/posts/_posts%2F2022-01-10-hello-world.md` would SSR the Markdown content located in `src/_posts/2022-01-10-hello-world.md`.

{%@ Note do %}
If you're wondering "but, uh, where's the HTML rendering part?!", the Bridgetown Roda configuration automatically handles the rendering of any models or resources which are returned in a route block.
{% end %}

SSR is great for generating preview content on-the-fly, but you can use it for any number of instances where it’s not feasible to pre-build your content. In addition, you can use SSR to “refresh” stale content…for example, you could pre-build all your product pages statically, but then request a newer version of the page (or better yet, just a fragment of it) whenever the static page is viewed which would then contain the up-to-date pricing (perhaps coming from a PostgreSQL database or some other external data source). And if you cache _that_ data using Redis in, say, 10-minute increments, you’ve just built yourself an extremely performant e-commerce solution. This is only a single example!

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

### Accessing the Current Site, Collections, and Resources

You can use the `bridgetown_site` helper in your Roda code to access the current site object. From there, you can access data, collections, and resources for aid in rendering. For example, if you knew of a particular resource by title you wanted to find, you could write:

```ruby
bridgetown_site.collections.posts.resources.find { _1.data.title == "My Post" }
```

You can return a resource at the end of any Roda block to have it render out automatically, or you could pass it along as data to some other resource, or use some resource data within a return string or hash value (which autoconverts to JSON).

{%@ Note type: :warning do %}
  #### Performance considerations around loaded content

  By default, all available collections are read in when the Roda server boots up. This might not be a big deal in production since it's a one-time procedure, but bear in mind that on large sites, having all that data loaded in memory could prove costly. In addition, in development, any time you make a change to a file and the site rebuilds, resources are re-read into memory.

  You can configure collections, including the built-in pages and posts collections, to be skipped when your site's running in SSR mode. Just set `skip_for_ssr` to `true` for collection metadata in your config file. For example, to skip reading posts in `config/initializers.rb`:

  ```ruby
  Bridgetown.configure do
    # other configuration here

    collections do
      posts do
        skip_for_ssr true
      end
    end
  end
  ```

  Most of the time though, on modestly-sized sites, this shouldn't prove to be a major issue.
{% end %}

## File-based Dynamic Routes

**But wait, there’s more!** We also provide a plugin called `bridgetown-routes` which gives you the ability to write file-based dynamic routes with integrated view templates right inside your source folder.

To opt-into the `bridgetown-routes` gem, make sure it's enabled in your `Gemfile`:

```ruby
gem "bridgetown-routes"
```

and added in `config/initializers.rb`:

```ruby
init :"bridgetown-routes"
```

A file-based route is comprised of two parts:

* A Roda block at the top, contained within special delimiters. This block is processed initially when the route URL is accessed, and before any template rendering has begun.
* A view template underneath the Roda block, rendered via the `render_with` method inside the Roda block.

A Roda block can contain a single route handler via `r.get`, or you can add additional handling of HTTP methods (`r.post`, etc.) or even sub-routes—though it's recommended to stay simple and use individual file-based routes as much as possible. Note that if even if you define multiple route types in your Roda block, you only have a single template per-route.

Let's take a look at how this all works. First, an example of a route saved to `src/_routes/items/index.erb`. It provides the `/items` URL which shows a list of item links:

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
  <% data.items.each do |item| %>
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

<p><strong>Item ID:</strong> <%= data.item_id %></p>

<p><strong>Item SKU:</strong> <%= data.item_sku %></p>

```

This is a contrived example of course, but you can easily imagine loading a specific item from a data source based on the incoming parameter(s) and providing that item data to the view, all within a single file.

You can even use placeholders in folder names! A route saved to `src/_routes/books/[id]/chapter/[chapter_id].erb` would match to something like `/books/234259/chapter/5` and let you access `r.params[:id]` and `r.params[:chapter_id]`. Pretty nifty.

Testing is straightforward as well. Simply place `.test.rb` files alongside your routes, and you’ll be able to use Capybara to write **fast** integration tests including interactions requiring Javascript (assuming Cuprite is also installed). (_docs coming soon_)

### Route Template Delimiters

Bridgetown lets you use a few different delimiters for the Roda block at the top, depending on your template format. For example, `---<%` and `%>---` would work well for an `.erb` file, but `###ruby` and `###` would be ideal for an `.rb` file.

See [Ruby Front Matter](/docs/front-matter#the-power-of-ruby-in-front-matter) for additional details (not that a Roda block is front matter, but the delimiters used are the same).

### Routes in Islands Architecture

You can add routes folders inside of one or more islands. For example, you could add a route file at `src/_islands/paradise/routes/dreamy.erb`, and the URL would then resolve to the island name plus the route name (`/paradise/dreamy`). If you name your route file `index.(ext)`, then the route path would be just the island name (`/paradise`).

For more information about islands, read our [Islands Architecture documentation](/docs/islands).

## URL Helpers

You can use the `relative_url` and `absolute_url` helpers within your Roda code any time you need to reference a particular URL, to ensure any base path or locale prefix gets added automatically. It also will work with any object which responds to a method like `relative_url` or `url`. For example:

```rb
r.redirect relative_url("/path/to/page")

r.redirect relative_url(obj)
```

<!--
## Roda Helpers

Flash, session, cookies, CSRF, etc.
-->

<!---
## Deployment

-->

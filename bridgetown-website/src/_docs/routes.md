---
title: Server-Rendered Routes
order: 250
top_section: Architecture
category: routes
---

Bridgetown comes with a production-ready web server based on the battle-hardened one-two punch of [Rack](https://github.com/rack/rack) + [Puma](https://puma.io). On top of Puma we've layered on [Roda](http://roda.jeremyevans.net), a refreshingly fast & lightweight web routing toolkit created by Jeremy Evans. On a basic level, it handles serving of all statically-built site files you access when you run `bin/bridgetown start`.

Bridgetown lets you create your own Roda-based API routes in the `server/routes` folder. An example ships in each new Bridgetown project for you to examine (`server/routes/hello.rb.sample`). These routes provide the standard features you may be accustomed to if you've used Roda standalone.

However, to take full advantage of all the Bridgetown has to offer, we recommend you load up our SSR and Dynamic Routes plugins. Add to your configuration in `config/initializers.rb`:

```rb
init :ssr # add `sessions: true` if you want to save session data, use flash, etc.
# or:
init :"bridgetown-routes" # inits ssr automatically
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

        if item.content.empty?
          response.status = 404
          next Bridgetown::Model::Base.find("repo://pages/_pages/404.html")
        end

        item
      end
    end
  end
end
```

This route handles any `/preview/:collection/:path` URLs which are accessed like any other statically-generated resource. It will find a content item via a repo origin ID and render that item as HTML. For example: `/preview/posts/_posts%2F2022-01-10-hello-world.md` would SSR the Markdown content located in `src/_posts/2022-01-10-hello-world.md`.

{%@ Note do %}
If you're wondering "but, uh, where's the HTML rendering part?!", the Bridgetown Roda configuration automatically handles the rendering of any models or resources which are returned in a route block. This is based on a "callable" interface which you can also use for your own custom objects! More on that down below.
{% end %}

SSR is great for generating preview content on-the-fly, but you can use it for any number of instances where it’s not feasible to pre-build your content. In addition, you can use SSR to “refresh” stale content…for example, you could pre-build all your product pages statically, but then request a newer version of the page (or better yet, just a fragment of it) whenever the static page is viewed which would then contain the up-to-date pricing (perhaps coming from a PostgreSQL database or some other external data source). And if you cache _that_ data using Redis in, say, 10-minute increments, you’ve built yourself an extremely performant e-commerce solution. This is only a single example!

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

You can use the `site` helper (also aliased `bridgetown_site`) in your Roda code to access the current site object. From there, you can access data, collections, and resources for aid in rendering. For example, if you knew of a particular resource by title you wanted to find, you could write:

```ruby
site.collections.posts.find { _1.data.title == "My Post" }
```

You can return a resource at the end of any Roda block to have it render out automatically, or you could pass it along as data to some other resource, or use some resource data within a return string or hash value (which autoconverts to JSON).

{%@ Note type: :warning do %}
  #### Performance considerations around loaded content

  By default, all available collections are read in when the Roda server boots up. This might not be a big deal in production since it's a one-time procedure, but bear in mind that on large sites, having all that data loaded in memory could prove costly. In addition, in development, any time you make a change to a file and the site rebuilds, resources are re-read into memory.

  You can configure collections, including even the built-in pages and posts collections, to be skipped when your site's running in SSR mode. Set `skip_for_ssr` to `true` for collection metadata in your config file. For example, to skip reading posts in `config/initializers.rb`:

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

## Rendering Viewable Components

For a traditional "VC" part of the MVC (Model-View-Controller) programming paradigm, Bridgetown provides a `Viewable` mixin for [components](/_docs/components). This lets you offload the rendering of a view to a component, keeping your Roda route very clean.

```ruby
# ./server/routes/products.rb

class Routes::Products < Bridgetown::Rack::Routes
  route do |r|
    r.on "products" do
      # route: /products/:sku
      r.get String do |sku|
        # Tip: check out bridgetown_sequel plugin for database connectivity!
        Views::Product.new product: Product.find(sku:)
      end
    end
  end
end

# ./src/_components/views/product.rb

class Views::Product < Bridgetown::Component
  include Bridgetown::Viewable

  def initialize(product:)
    @product = product

    data.title = @product.title
  end

  # @param app [Roda] this is the instance of the Roda application
  def call(app)
    render_with(app) do
      layout :page
      page_class "product"
    end
  end
end

# ./src/_components/views/product.erb is an exercise left to the reader
```

[Read more about the callable objects pattern below.](#callable-objects-for-rendering-within-blocks)

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

* A Roda block at the top, contained within special delimiters. This block is processed initially when the route URL is accessed, and before any template rendering has begun. You can include Ruby front matter here, just like you would with static resource content.
* A view template underneath the Roda block, which is rendered in the correct format based on the file extension (ERB, etc.) and has access to front matter and local variables from the Roda block.

A Roda block can contain a single route handler via `r.get`, or you can add additional handling of HTTP methods (`r.post`, etc.) or even sub-routes—though it's recommended to stay simple and use individual file-based routes as much as possible. Note that if even if you define multiple route types in your Roda block, you can only have a single template per-route.

Let's take a look at how this all works. First, an example of a route saved to `src/_routes/items/index.erb`. It provides the `/items` URL which shows a list of item links:

```eruby
---<%
# route: /items
r.get do
  # sample data:
  items = [
    { number: 1, slug: "123-abc" },
    { number: 2, slug: "456-def" },
    { number: 3, slug: "789-xyz" },
  ]

  render_with do
    layout :page
    title "Dynamic Items"
  end
end
%>---

<ul>
  <% items.each do |item| %>
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

  render_with do
    layout :page
    title "Item Page"
  end
end
%>---

<p><strong>Item ID:</strong> <%= item_id %></p>

<p><strong>Item SKU:</strong> <%= item_sku %></p>

```

This is a contrived example of course, but you can easily imagine loading a specific item from a data source based on the incoming parameter(s) and providing that item data to the view, all within a single file.

You can even use placeholders in folder names! A route saved to `src/_routes/books/[id]/chapter/[chapter_id].erb` would match to something like `/books/234259/chapter/5` and let you access `r.params[:id]` and `r.params[:chapter_id]`. Pretty nifty.

<!--
To add tests, place `.test.rb` files alongside your routes. You can then use Capybara to write **fast** integration tests including interactions requiring Javascript (assuming Cuprite is also installed). (_docs coming soon_)
-->

### Route Template Delimiters, Front Matter Syntax

Bridgetown lets you use a few different delimiters for the Roda block at the top, depending on your template format. For example, `---<%` and `%>---` would work well for an `.erb` file, but `###ruby` and `###` would be ideal for an `.rb` file.

See [Ruby Front Matter](/docs/front-matter#the-power-of-ruby-in-front-matter) for additional details.

The Roda block also excepts a couple of different styles of specifying front matter. You can use `render_with do ... end` as in the examples above, but you can also use a data hash instead:

```ruby
hsh = { layout: :page, title: "I'm a Page!" } 

render_with(data: hsh)
```

Note that if you use that syntax, additional local variables will _not_ be copied down to the view template.

Finally, if you only need to use local variables within your front matter, you can omit `render_with` entirely:

```eruby
---<%
referrer = params[:ref]
referrer = "=)" unless AllowedValidator.valid?(referrer) # just a demo

title = "Thank You!"
%>---

<h1><%= title %></h1>

<p>We appreciate your business, <%= referrer %></h1>
```

### Routes in Islands Architecture

You can add routes folders inside of one or more islands. For example, you could add a route file at `src/_islands/paradise/routes/dreamy.erb`, and the URL would then resolve to the island name plus the route name (`/paradise/dreamy`). If you name your route file `index.(ext)`, then the route path would be only the island name (`/paradise`).

For more information about islands, read our [Islands Architecture documentation](/docs/islands).

### Adding Additional Route Paths

If you'd like to add any arbitrary path as a location for route files—even outside of the project root—you can do so in your `config/initializers.rb`:

```ruby
Bridgetown.configure do |config|
  # configuration here

  init :"bridgetown-routes", additional_source_paths: File.expand_path("more_routes", "#{root_dir}/..")
end
```

## URL Helpers

You can use the `relative_url` and `absolute_url` helpers within your Roda code any time you need to reference a particular URL, to ensure any base path or locale prefix gets added automatically. It also will work with any object which responds to a method like `relative_url` or `url`. For example:

```rb
r.redirect relative_url("/path/to/page")

r.redirect relative_url(obj)
```

## Callable Objects for Rendering within Blocks

When authoring Roda blocks, you have the option of returning resources to be rendered out as HTML or other text-based formats.

But it's also possible to return any object which includes the `Bridgetown::RodaCallable` mixin and defines a `call` method which accepts the Roda application as the argument. For example, if you wrote an object which generates an RSS feed, you could use it like so:

```ruby
class MyRssFeed
  include Bridgetown::RodaCallable

  def call(app)
    app => { request:, response: } # now you have those as local variables

    feed_xml = generate_the_feed # an exercise left to the reader

    response["Content-Type"] = "application/rss+xml" # set the correct content type
    feed_xml # return XML string
  end  
end
```

```ruby
# Use the object directly in a Roda block:
r.get "/my-feed.xml" do
  MyRssFeed.new
end
```

For the Roda-curious, we've enabled this behavior via our own custom handler for the `custom_block_results` Roda plugin.

And [as mentioned previously](#rendering-viewable-components), the `Viewable` component mixin is a wrapper around `RodaCallable` to add some extra smarts to [Ruby components](/docs/components):

* You can access the `data` hash from within your component to add and retrieve front matter for the view.
* You can call `front_matter` with a block to define [Ruby Front Matter](/docs/front-matter#the-power-of-ruby-in-front-matter) for the view.
* From your `call(app)` method, you can call `render_in_layout(app)` to render the component template within the layout defined via your front matter.
* Or for a shorthand, call `render_with(app) do ... end` to specify Ruby Front Matter and render the template in one pass.

You can even cascade multiple callable objects, if you really want a full object-oriented MVC experience:

```ruby
# ./server/routes/products.rb

class Routes::Reports < Bridgetown::Rack::Routes
  route do |r|
    r.on "reports" do
      # route: /reports/:id
      r.get Integer do |id|
        Controllers::Reports::Show.new(id:)
      end
    end
  end
end

# ./server/controllers/reports/show.rb

class Controllers::Reports::Show
  include Bridgetown::RodaCallable

  def initialize(id:)
    @id = id
  end

  def call(app)
    app => { request:, response: }

    report = Report[@id]

    # do other bits of controller-y logic here

    # render a Viewable component
    Views::Reports::Show.new(report:)
  end
end
```

<!--
## Roda Helpers

Flash, session, cookies, CSRF, etc.
-->

## Building Web Applications With Roda

Besides the features that Bridgetown uniquely provides, described thus far, many of the features you'll use in the typical course of building out an application are directly supplied by Roda.

Bridgetown comes with what we like to call an "opinionated distribution" of Roda. Unlike a first install of Roda where no plugins have yet to be configured, Bridgetown configures a number of plugins right out of the box for enhanced developer experience.

[Read our Roda reference guide](/docs/roda) for more on this base configuration, as well as some of the helpers and utilities made available.

<!---
## Deployment

-->

---
title: HTTP Requests and the Resource Builder
order: 0
top_section: Configuration
category: plugins
---

In this section, you'll learn how to make web requests and easily parse the response to save site data or construct new resources like blog posts or collection entries.

Here's an example of making an HTTP GET request to a remote API, looping through an array parsed from the JSON response, and saving new posts based on each item:

```ruby
class LoadPostsFromAPI < SiteBuilder
  def build
    get "https://domain.com/posts.json" do |data|
      data.each do |post|
        add_resource :posts, "#{post[:slug]}.md" do
          ___ post
          layout :post
          categories post[:taxonomy][:category].map { |category| category[:slug] }
          date Bridgetown::Utils.parse_date(post[:date])
          content post[:body]
        end
      end
    end
  end
end
```

{{ toc }}

## Making a Request

To make a request, simply call the `get` method inside of `build` in your builder class:

```ruby
def build
  get url do |data|
    site.data[:remote_api_info] = data
  end
end
```

By default, the request will expect and parse JSON data from the remote endpoint. To bypass this and access raw text instead, set the `parse_json` keyword to `false`:

```ruby
def build
  get url, parse_json: false do |data|
    # do something with the raw text, HTML, CSV, etc.
  end
end
```

You can also customize the HTTP headers sent with the request. For example, you might want to use an auth token to access protected resources:

```ruby
def build
  get url, headers: {"Authorization" => "Bearer #{config["api_key"]}"} do |data|
    # data for your eyes only
  end
end
```

## Customizing the Connection Object

Bridgetown uses the [Faraday gem](https://lostisland.github.io/faraday/) under the hood to make web requests. If you need to customize the default usage of Faraday—perhaps to set additional defaults or inject middleware to adjust the request or response logic—simply override the `connection` method in your builder class.

Here's an example of using Retry middleware to ensure requests are attempted multiple times before admitting defeat:

```ruby
def connection(headers: {}, parse_json: true)
  retry_options = {
    max: 2,
    interval: 0.05,
    interval_randomness: 0.5,
    backoff_factor: 2
  }

  super do |faraday|
    faraday.request :retry, retry_options
  end
end
```

Bridgetown comes with the [Faraday Middleware gem](https://github.com/lostisland/faraday_middleware) out-of-the-box and utilizes a few of its options such as following redirects (if necessary). You can `require` additional middleware to add to your Faraday connection if you like. You can also write your own Faraday middleware, but that's an advanced usage and typically not needed.

{%@ Note do %}
  #### What’s the Deal with HTTP Methods?

  Why is only the HTTP GET method supported? What about POST, PUT, etc.? Well the idea behind making requests as part of the site build process is that it's a one-way data flow: you get data from the API to add to your site, and you don't attempt any remote alterations to that data. If your API requires you to make a request using a method such as POST, please let them know you'd like a GET method as well. As a last resort, you can also use the provided Faraday `connection` object to construct a custom request. See the Faraday documentation for further details.
{% end %}

## The Resource Builder

Adding content from an API to the `site.data` object is certainly useful, but an even more powerful feature is the Resource Builder. All you need to do is call the `add_resource` method to generate resources which function in exactly the same way as if those files were already stored in your repository. It uses a special DSL, similar to [Ruby Front Matter](/docs/front-matter), to make assigning front matter and content very simple.

Here's a simple example of creating a new blog post:

```ruby
def build
  add_resource :posts, "2020-05-17-way-to-go-bridgetown.md" do
    layout :post
    title "Way to Go, Bridgetown!"
    author "rlstevenson"
    content "It's pretty _nifty_ that you can add **new blog posts** this way."
  end
end
```

This is the programmatic equivalent of saving a new file `src/_posts/2020-05-17-way-to-go-bridgetown.md` with the following contents:

```yaml
---
title: Way to Go, Bridgetown!
author: rlstevenson
---

It's pretty _nifty_ that you can add **new blog posts** this way.
```

### Collections

You can save a resource in any collection:

```ruby
add_resource :authors, "rlstevenson.md" do
  name "Robert Louis Stevenson"
  born 1850
  nationality "Scottish"
end
```

You don't even need to use a collection that's previously been configured in `bridgetown.config.yml`. You can make up new collections and use existing layouts to place your content within the appropriate templates, assuming the expected front matter is compatible.

```ruby
add_resource :blogish, "fake-blog-post.html" do
  layout :post
  title "I'm a blog post…sort of"
  date "2020-05-17"
  content "<p>I might look like a blog post, but I'm <em>not!</em></p>"
end
```

That resource would then get written out to the `/blogish/fake-blog-post/` URL.

Another aspect of the Resource Builder to keep in mind is that `content` is a "special" variable. Everything except `content` is considered [front matter](/docs/front-matter), and `content` is everything you'd add to a file after the front matter.

### Customizing Permalinks

If you'd like to customize the [permalink](/docs/content/permalinks) of a new resource, you can specifically set the `permalink` front matter variable:

```ruby
add_resource :posts, "blog-post.md" do
  title "Strange Paths"
  date "2019-07-23"
  permalink "/path/to/the/:slug/"
  content "…"
end
```

The post would then be accessible via `/path/to/the/blog-post/`.

### Merging Hashes Directly into Front Matter

If you have a hash of variables you'd like to merge into a resource's front matter, you can use the `___` method.

```ruby
vars = {
  title: "I'm a Draft",
  categories: ["category1", "category2"],
  published: false
}

add_resource :posts, "post.html" do
  ___ vars
end
```

This is great when you have data coming in from external APIs and you'd just like to inject all of that data into the front matter with a single method call.

Bear in mind that this doesn't include your `content` variable. So you'll still need to set that separately when using the `___` method, for example:

```ruby
get article_url do |data|
  add_resource :pages, "articles/#{data[:slug]}.html" do
    ___ data
    content data[:body]
  end
end
```

## DSL Scope

If you're not familar with Ruby DSLs, you may run into an issue where you need to call a method from your builder plugin within `add_resource` and it's not in scope. For example, this won't work:

```ruby
def string_value
  "I'm a string!"
end

def build
  add_resource :pages, "page.html" do
    title string_value
    content "Page content."
  end
end
```

The reason it won't work is because in this example, `title` is actually interpreted as a method call within the DSL block, which means `string_value` is a similar call. That would be fine if you'd already added `string_value` as a front matter key, in which case `string_value` would return that front matter variable. But in this case, you want to use the `string_value` method of your plugin.

To accomplish that, simply provide a lambda using the `from: -> { }` syntax. Let's rewrite the above example to work as expected:

```ruby
def string_value
  "I'm a string!"
end

def build
  add_resource :pages, "page.html" do
    title from: -> { string_value }
    content "Page content."
  end
end
```

Now the `title` front matter variable will be set to "I'm a string".

## Builder Lifecycle and Data Files

Something to bear in mind is that that code in your `build` method is run as part of the site's `pre_read` [hook](/docs/plugins/hooks), which means that no data or content in your site repository has yet been loaded at that point. So you can't, say, build resources based on existing [data files](/docs/datafiles) as you might assume:

```ruby
def build
  # THIS WON'T WORK!!!
  site.data[:stuff_from_the_repo].each do |k, v|
    add_resource :stuff, "#{k}.md" do
      ___ v
      content v[:content]
    end
  end
end
```

Instead, what you can do is define a `post_read` custom hook and _then_ read in the data:

```ruby
def build
  hook :site, :post_read do
    site.data[:stuff_from_the_repo].each do |k, v|
      add_resource :stuff, "#{k}.md" do
        ___ v
        content v[:content]
      end
    end
  end
end
```

## What About GraphQL?

Bridgetown has first-class support for GraphQL using a plugin called
[Graphtown](https://github.com/whitefusionhq/graphtown).

Graphtown allows you to consume GraphQL APIs for your Bridgetown website
using a tidy Builder DSL on top of the
[Graphlient](https://github.com/ashkan18/graphlient) gem.

Get started by simply running `bundle add graphtown -g
bridgetown_plugins` in your bridgetown site.

Then, navigate to your `plugins/site_builder.rb` file and add the
Graphtown mixin.

```rb
# plugins/site_builder.rb

class SiteBuilder < Bridgetown::Builder
  include Graphtown::QueryBuilder
end
```

Setup your `graphql_endpoint` in your `bridgetown.config.yml` and
you're ready to rock and roll.

```rb
# bridgetown.config.yml

graphql_endpoint: http://localhost:1337/graphql
```

For more details on how to use the Graphtown gem to pull in your data
from a CMS, check out the project on Github.
[https://github.com/whitefusionhq/graphtown](https://github.com/whitefusionhq/graphtown)

## Conclusion

As you've seen from these examples, using data from external APIs to create new content for your Bridgetown website is easy and straightforward with the `get` and `add_resource` methods provided by the Builder API. While there are numerous benefits to storing content directly in your site repository, Bridgetown gives you the best of both worlds—leaving you simply to decide where you want your content to live and how you'll put it to good use as you build your site.

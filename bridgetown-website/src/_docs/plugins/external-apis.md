---
title: HTTP Requests and the Document Builder
hide_in_toc: true
order: 0
category: plugins
---

New in Bridgetown 0.14 as part of the Builder API is the ability to make web requests and easily parse the response to save site data or construct new documents like blog posts or collection entries.

Here's an example of making an HTTP GET request to a remote API, looping through an array parsed from the JSON response, and saving new posts based on each item:

```ruby
class LoadPostsFromAPI < SiteBuilder
  def build
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

{% toc %}

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

{% rendercontent "docs/node" %}
Why is only the HTTP GET method supported? What about POST, PUT, etc.? Well the idea behind making requests as part of the site build process is that it's a one-way data flow: you get data from the API to add to your site, and you don't attempt any remote alterations to that data. If your API requires you to make a request using a method such as POST, please let them know you'd like a GET method as well. As a last resort, you can also use the provided Faraday `connection` object to construct a custom request. See the Faraday documentation for further details.
{% endrendercontent %}

## The Document Builder

Adding content from an API to the `site.data` object is certainly useful, but an even more powerful feature recently added to Bridgetown is the Document Builder. All you need to do is call the `doc` method to generate Post and Collection documents which function in exactly the same way as if those files were already stored in your repository.

Here's a simple example of creating a new blog post:

```ruby
def build
  doc "2020-05-17-way-to-go-bridgetown.md" do
    title "Way to Go, Bridgetown!"
    author "rlstevenson"
    content "It's pretty _nifty_ that you can add **new blog posts** this way."
  end
end
```

This is the programmatic equivalent of saving a new file `src/_posts/2020-05-17-way-to-go-bridgetown.md` with the following contents:

```yaml
---
title: Way to Go, Bridgetown
author: rlstevenson
---

It's pretty _nifty_ that you can add **new blog posts** this way.
```

### Collections

By default, documents are saved in the posts collection, but you can save a document in any collection:

```ruby
doc "rlstevenson.md" do
  collection "authors"
  name "Robert Louis Stevenson"
  born 1850
  nationality "Scottish"
end
```

You don't even need to use a collection that's previously been configured in `bridgetown.config.yml`. You can make up new collections and use existing layouts to place your content within the appropriate template, assuming the front matter is compatible.

```ruby
doc "fake-blog-post.html" do
  collection "blogish"
  layout "post"
  title "I'm a blog post…sort of"
  date "2020-05-17"
  content "<p>I might look like a blog post, but I'm <em>not!</em></p>"
end
```

That document would then get written out to the `/blogish/fake-blog-post` URL.

Another aspect of the Document Builder to keep in mind is that `content` is a "special" variable. Everything except `content` is considered [front matter](/docs/front-matter), and `content` is everything you'd add to a file after the front matter.

### Customizing Permalinks

If you'd like to customize the permalink of a new document, you can specifically set the `permalink` front matter variable…but an even easier way to do it is just start your filename with a path. For example:

```ruby
doc "/path/to/the/blog-post.md" do
  title "Strange Paths"
  date "2019-07-23"
  content "…"
end
```

The post would then be accessible via `/path/to/the/blog-post`.

### Merging Hashes Directly into Front Matter

If you have a hash of variables you'd like to merge into a document's front matter, you can use the `front_matter` method.

```ruby
vars = {
  title: "I'm a Draft",
  categories: ["category1", "category2"],
  published: false
}

doc "post.html" do
  front_matter vars
end
```

This is great when you have data coming in from external APIs and you'd just like to inject all of that data into the front matter with a single method call.

Bear in mind that this doesn't include your `content` variable. So you'd still need to set that separately when using the `front_matter` method, for example:

```ruby
get article_url do |data|
  doc "new-article.html" do
    front_matter data
    content data[:body]
  end
end
```

## Builder Lifecycle and Data Files

Something to bear in mind is that that code in your `build` method is run as part of the site's `pre_read` [hook](/docs/plugins/hooks), which means that no data or content in your site repository has yet been loaded at that point. So you can't, say, build documents based on existing [data files](/docs/datafiles) as you might assume:

```ruby
def build
  # THIS WON'T WORK!!!
  site.data[:stuff_from_the_repo].each do |k, v|
    doc "#{k}.md" do
      collection "stuff"
      front_matter v
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
      doc "#{k}.md" do
        collection "stuff"
        front_matter v
        content v[:content]
      end
    end
  end
end
```

You also can't use the `doc` method inside of a [generator](/docs/plugins/generators) block/method or a [Liquid](/docs/plugins/tags) tag/filter, because by the time your code executes the build process has already run the internal generator which handles `doc`-based documents.

```ruby
def build
  generator do
    doc "this-wont-work.html" do
      title "Oops…"
    end
  end
end
```

So basically you'll want to contain usage of the Document Builder to either directly in the `build` method or inside of a `post_read` hook.

## What About GraphQL?

Bridgetown doesn't yet support GraphQL endpoints out-of-the-box, but that doesn't mean you can't use GraphQL today.

[Graphlient](https://github.com/ashkan18/graphlient) is a GraphQL client which lets you use a friendly Ruby DSL to consume GraphQL APIs. Using Graphlient and the Document Builder, you could do something like this:

```ruby
def build
  client = Graphlient::Client.new("https://test-graphql-cms.com/graphql")
  response = client.query do
    query do
      posts do
        slug
        title
        body
        taxonomies do
          name
        end
      end
    end
  end

  response.data.posts.each do |post|
    doc "#{post.slug}" do
      title post.title
      categories post.taxonomies.map(&:name)
      content post.body
    end
  end
end
```

## Conclusion

As you've seen from these examples, using data from external APIs to create new content for your Bridgetown website is easy and straightforward with the `get` and `doc` methods provided by the Builder API. While there are numerous benefits to storing content directly in your site repository, Bridgetown gives you the best of both worlds—leaving you simply to decide where you want your content to live and how you'll put it to good use as you build your site.
---
title: HTTP Requests and the Document Builder
hide\_in\_toc: true
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
          date Bridgetown::Utils.parse_date(post.date)
          content data.body
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

Bridgetown uses the [Faraday gem](https://lostisland.github.io/faraday/) under the hood to make web requests. If you need to customize the default usage of Faraday—perhaps to set additional defaults or inject middleware to adjust the request logic—simply override the `connection` method in your builder class.

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

Bridgetown comes out-of-the-box with the extra [Faraday Middleware gem](https://github.com/lostisland/faraday_middleware) and utilizes a few of the available options such as following redirects if necessary. You can `require` additional middleware if you like to add to your Faraday connection.

{% rendercontent "docs/node" %}
Why is only the HTTP GET method supported? What about POST, PUT, etc.? Well the idea behind making requests as part of the site build process is that it's a one-way data flow: you get data from the API to add to your site, and you don't attempt any remote alterations to that data. If your API requires you to make a request using a method like POST, please let them know you'd like a GET method as well. As a last resort, you can also use the provided Faraday `connection` object to construct a custom request. See the Faraday documentation for further details.
{% endrendercontent %}

## The Document Builder

Use the `doc` method to create Post and Collection documents.

EXAMPLE

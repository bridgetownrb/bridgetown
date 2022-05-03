---
title: Helpers
order: 0
top_section: Configuration
category: plugins
---

Helpers are Ruby methods you can provide to Tilt-based templates ([ERB, Slim, etc.](/docs/template-engines/erb-and-beyond)) to transform data or output new content in various ways.

Example:

```ruby
class Builders::Helpers < SiteBuilder
  def build
    helper :cache_busting_url do |url|
      "http://www.example.com/#{url}?#{Time.now.to_i}"
    end
  end
end
```

```erb
<%= cache_busting_url "mydynamicfile.js" %>
```

outputs:

```
http://www.example.com/mydynamicfile.js?1586194585
```

## Supporting Arguments

You can accept multiple arguments to your helper by simply adding them to your block or method, and optional ones are simply specified with a default value (perhaps `nil` or `false`). For example:

```ruby
class Builders::Helpers < SiteBuilder
  def build
    helper :multiply_and_optionally_add do |input, multiply_by, add_by = nil|
      value = input * multiply_by
      add_by ? value + add_by : value
    end
  end
end
```

Then just use it like this:

```erb
5 times 10 equals <%= multiply_and_optionally_add 5, 10 %>

  output: 5 times 10 equals 50

5 times 10 plus 3 equals <%= multiply_and_optionally_add 5, 10, 3 %>

  output: 5 times 10 plus 3 equals 53
```

## Using Instance Methods

As with other parts of the Builder API, you can also use an instance method to register your helper:

```ruby
class Builders::Helpers < SiteBuilder
  def build
    helper :cache_busting_url, :bust_it
  end

  def bust_it(url)
    "http://www.example.com/#{url}?#{Time.now.to_i}"
  end
end
```

If your helper name and method name are the same, you can omit the second argument.

## Helper Execution Scope

By default, the code within the helper block or method is executed within the scope of the builder object. This means you will not have access to other helpers you may expecting to call. For example, if you want to call `slugify` from your helper, it will cause an error.

To remedy this, simply pass the `helpers_scope: true` argument when defining a helper block. Then you can call other helpers as part of your code block (but not methods within your builder).

```ruby
class Builders::Helpers < SiteBuilder
  def build
    helper :slugify_and_upcase, helpers_scope: true do |url|
      slugify(url).upcase
    end
  end
end
```

When using the helpers scope, you have access to two variables: `site` and `view`. `site` is of course an instance of `Bridgetown::Site`, and `view` will be a subclassed instance of `Bridgetown::RubyTemplateView` which reflects the current template engine in use. For example, it will be `Bridgetown::ERBView` for ERB templates. This gives you access to engine-specific view methods such as `partial`, as well as any other custom methods that may have been defined for the view to use.

## Using the Capture Helper

Within the helpers scope, you can "capture" the contents of a block and use that text inside your helper. Optionally, you can pass an object to the block itself from your helper. For example:

```ruby
class Builders::Helpers < SiteBuilder
  def build
    helper :capture_and_upcase, helpers_scope: true do |&block|
      label = "upcased"
      view.capture(label, &block).upcase
    end
  end
end

```

Now just call that helper in your template and use the `label` argument:

```eruby
<%= capture_and_upcase do |label| %>
  I have been <%= label %>!
<% end %>

  output: I HAVE BEEN UPCASED!
```

## Helpers vs. Filters vs. Tags

Filters and tags are aspects of the [Liquid](/docs/template-engines/liquid) template engine which comes installed by default. The behavior of both filters and tags are roughly analogous to helpers in [Tilt-based templates](/docs/template-engines/erb-and-beyond). Specialized Bridgetown filters are also made available as helpers, as are a few tags such as `webpack_path`.
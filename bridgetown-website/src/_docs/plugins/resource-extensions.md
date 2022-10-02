---
title: Resource Extensions
order: 0
top_section: Configuration
category: plugins
---

This API allows you or a third-party gem to augment resources with new methods. There are two ways to use it: in a Builder via a <abbr title="Domain-Specific Language">DSL</abbr> method, or by defining your own modules to register as an extension. The Builder way works just with Ruby-based templates (ERB, etc.), whereas the module way can work with the Resource Liquid Drop as well.

There's also a summary extension point which can allow a plugin to provide enhanced summaries for resource content.

## Builder-based Extensions

You can use the `define_resource_method` DSL with a block to add a new method onto all `Bridgetown::Resource::Base` objects.

```ruby
def build
  define_resource_method :upcased_title do
    data.title.upcase
  end
end
```

```erb
<!-- some ERB template -->
Title: <%= resource.upcased_title %>
```

Note that the block passed to `define_resource_method` is evaluated within the scope of a resource instance, which is why it's calling `data` directly rather than, say, `resource.data`. Your local builder methods won't be available within the block—however, any variables will be captured within the scope, so if you add `builder = self`, you can reference the builder within the block by calling `builder`.

Alternatively, you can define the method directly on your builder, so then when the resource method is called, it transparently delegates to the builder. The `resource` accessor will be available within your method (assuming the method is called via delegation).

```ruby
def build
  define_resource_method :upcased_content
end

def upcased_content
  resource ? resource.content.upcase : nil
end
```

Also, you can add a resource class method by passing the `class_scope: true` argument:

```ruby
def build
  define_resource_method :resource_class_name, class_scope: true do
    "All your #{name} are belong to us!"
  end
end

# After the build step:
Bridgetown::Resource::Base.resource_class_name
# => "All your Bridgetown::Resource::Base are belong to us!"
```

## Module-based Extensions

You can use the `Bridgetown::Resource.register_extension` method to mixin modules to the resource base. Here's an example of extending both Liquid Drop and Ruby resource objects:

```ruby
module TestResourceExtension
  def self.return_string
    "return value"
  end

  module LiquidResource
    def heres_a_liquid_method
      "Liquid #{TestResourceExtension.return_string}"
    end
  end

  module RubyResource
    def heres_a_method(arg = nil)
      "Ruby #{TestResourceExtension.return_string}! #{arg}"
    end
  end
end

Bridgetown::Resource.register_extension TestResourceExtension
```

Now in any Ruby template or other scenario, you can call `heres_a_method` on a resource:

```ruby
site.resources.first.heres_a_method
```

Or in Liquid, it'll be available through the drop:

{% raw %}
```liquid
{{ site.resources[0].heres_a_liquid_method }}
```
{% endraw %}

The extension itself can be any module whatsoever, doesn't matter—as long as you provide a sub-module of `RubyResource` and optionally `LiquidResource`, you're golden.

## Resource Summaries

By default the first line of content is returned when `resource.summary` is called, but any resource extension can provide a new way to summarize resources by defining `summary_extension_output`.

```ruby
def build
  define_resource_method :summary_extension_output do
    "SUMMARY! #{content.strip[0..10]} DONE"
  end
end
```

Your plugin might provide detailed semantic analysis using AI, or call out to a 3rd-party API (and ideally cache the results for better performance)…anything you can imagine.
---
title: Ruby Components
template_engine: erb
category: components
hide_in_toc: true
order: 0
---

Starting in Bridgetown 0.18 and greatly enhanced in 0.21, you can render Ruby objects directly in your Ruby-based templates! This provides the basis for a fully-featured view component architecture for ERB and beyond.

A component is a reusable piece of template logic that can be included in any part of the site, and a full suite of components can comprise what is often called a "design system".

Ruby components can be combined with front-end component strategies using **web components** or other JavaScript libraries/frameworks for a [hybrid static/dynamic approach](/docs/components#hybrid-components){:data-no-swup="true"}.

<%= toc %>

## Basic Building Blocks

Bridgetown automatically loads `.rb` files you add to the `src/_components` folder, so that's likely where you'll want to save your component class definitions. It also load components from plugins which provide a `components` source manifest. Bridgetown's component loader is based on [Zeitwerk](https://github.com/fxn/zeitwerk){:rel="noopener"}, so you'll need to make sure you class names and namespaces line up with your component folder hierarchy (e.g., `_components/shared/navbar.rb` should define `Shared::Navbar`.).

To create a Ruby component, all you have to do is define a `render_in` method which accepts a single `view_context` argument as well as optional block. Whatever string value you return from the method will be inserted into the template. For example:

```ruby
class MyComponent
  def render_in(view_context, &block)
    "Hello from MyComponent!"
  end
end
```

```erb
<%%= render MyComponent.new %>

  output: Hello from MyComponent!
```

To pass variables along to a component, simply write an `initialize` method. You can also use Ruby's "squiggly heredoc" syntax as a kind of template language:

```ruby
class FieldComponent
  def initialize(type: "text", name:, label:)
    @type, @name, @label = type, name, label
  end

  def render_in(view_context)
    <<~HTML
      <field-component>
        <label>#{@label}</label>
        <input type="#{@type}" name="#{@name}" />
      </field-component>
    HTML
  end
end
```

```erb
<%%= render FieldComponent.new(type: "email", name: "email_address", label: "Email Address") %>

  output:
  <field-component>
    <label>Email Address</label>
    <input type="email" name="email_address" />
  </field-component>
```

<%= liquid_render "docs/note", type: "warning", extra_margin: true do %>
Bear in mind that Ruby components aren't accessible from Liquid templates. So if you need a component which can be used in either templating system, consider writing a Liquid component. [Read more information here.](/docs/components/liquid)
<% end %>

## Use Bridgetown::Component for Advanced Component Templates

While squggly heredocs are nice, what most people probably want to [the ability to write a template](/docs/erb-and-beyond) in ERB, Haml, Slim, or Serbea.

Starting in Bridgetown 0.21, you can subclass your components from `Bridgetown::Component` and then add a template file right next to the component's `.rb` file. The template will automatically get rendered by the component and you won't need to define a `render_in` method yourself. For example, if we were to translate the previous heredoc to a template-based component:

```ruby
# src/_components/field_component.rb
class FieldComponent < Bridgetown::Component
  def initialize(type: "text", name:, label:)
    @type, @name, @label = type, name, label
  end
end
```

```erb
<!-- src/_components/field_component.erb -->
<field-component>
  <label><%%= @label %></label>
  <input type="<%%= @type %>" name="<%%= @name %>" />
</field-component>
```

### Content

You also have access to a `content` variable within your component .rb/template file which is the output of the block passed into the component via `render`:

```erb
<!-- some page template -->
<%%= render(Layout::Box.new(border: :large)) do %>
  I'm in a box!
<%% end %>

<!-- src/_components/layout/box.erb -->
<layout-box border="<%%= @border %>">
  <%%= content %>
</layout-box>
```

If you need multiple "content areas" (sometimes known as slots), you can use the `capture` helper of the view context—and the fact `render` supplies the component itself as a block argument—like this:

```ruby
# src/_components/card.rb
class Card < Bridgetown::Component
  def initialize(title:, footer:)
    @title, @footer = title, footer
  end

  def image(&block)
    if block
      @_image_content = view_context.capture(&block)
      nil
    else
      content # make sure content block is first evaluated
      @_image_content
    end
  end
end
```

```erb
<!-- src/_components/card.erb -->
<app-card>
  <figure><%%= image %></figure>
  <header><%%= @title %></header>
  <app-card-inner>
    <%%= content %>
  </app-card-inner>
  <footer><%%= @footer %></footer>
</app-card>
```

```erb
<!-- some page template -->
<%%= render(Card.new(title: "Card Header", footer: "Card Footer")) do |c| %>
  <%% c.image do %><img src="<%%= resource.data.image %>" /><%% end %>

  Some card content goes here!
<%% end %>
```

### Helpers

As expected, helpers are available as well just like in standard templates:

```erb
<!-- src/_components/posts/excerpt.erb -->
<post-excerpt>
  <h3><%%= link_to @post.data.title, @post %></h3>
  
  <%%= markdownify @post.data.description %>
</post-excerpt>
```

While components are intended to be encapsulated, sometimes you want quick access to global data through `site`. In that case, you can set the `@site` instance variable and then the `site` accessor will be available in your component:

```ruby
class ExternalWidget < Bridgetown::Component
  def initialize(id:)
    @id = id
    @site = Bridgetown::Current.site
  end

  def before_render
    api_key = site.config.external_api_key
    # request data from a third-party service...
  end
end
```

### Lifecycle

In addition to simply rendering a template for you, `Bridgetown::Component` provides a couple lifecycle hooks:

* `render?` – if you define this method and return `false`, the component will not get rendered at all.
* `before_render` – called right before the component is rendered when the view_context is known and all helpers available.

## Need Compatibility with Rails? Try ViewComponent

If you've used GitHub's [ViewComponent](https://viewcomponent.org) in the past, you might be thinking by now that `Bridgetown::Component` feels an awful lot like `ViewComponent::Base`. And you're right! We've _intentionally_ modeled our component class off of what we think is one of the most exciting developments in Ruby on Rails view technology in a decade.

But we didn't stop there. Besides being able to use `Brigetown::Component` in your Bridgetown sites, you can actually use ViewComponent itself! How is this even possible?!

By creating a compatibility shim which "fools" ViewComponent into thinking it's booted up in a Rails app when it's actually not. ViewComponent itself is mainly only reliant on the ActionView framework within Rails, so we include that along with the shim, and then you're off to the races. There are a few gotchas you may need to work through depending on how you use ViewComponent, so let's break it down.

### Setup

First, you'll need to add the compatibility gem to your Gemfile (which will also add in ViewComponent as a dependency):

```
bundle add bridgetown-view-component -g bridgetown_plugins
```

Next...

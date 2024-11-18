---
title: Ruby Components
template_engine: erb
category: components
top_section: Designing Your Site
order: 0
---

A component is a reusable piece of template logic that can be included in any part of the site, and a full suite of components can comprise what is often called a "design system". You can render Ruby component objects directly in your Ruby-based templates, and you can render components from within other components. This provides the basis for a fully-featured view component architecture for ERB and beyond.

Ruby components can be combined with front-end component strategies using **web components** or other JavaScript libraries/frameworks.

<%= toc %>

## Basic Building Blocks

Bridgetown automatically loads `.rb` files you add to the `src/_components` folder, so that's likely where you'll want to save your component class definitions. It also load components from plugins which provide a `components` source manifest. Bridgetown's component loader is based on [Zeitwerk](https://github.com/fxn/zeitwerk), so you'll need to make sure your class names and namespaces line up with your component folder hierarchy (e.g., `_components/shared/navbar.rb` should define `Shared::Navbar`.).

To create a basic Ruby component, define a `render_in` method which accepts a single `view_context` argument as well as optional block. Whatever string value you return from the method will be inserted into the template. For example:

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

The `view_context` is whichever template or component processor is in charge of rendering this object.

Typically though, you won't be writing Ruby components as standalone objects.  Introducing `Bridgetown::Component`!

<%= render Note.new type: "warning" do %>
Bear in mind that Ruby components aren't accessible from Liquid templates. So if you need a component which can be used in either templating system, consider writing a Liquid component. [Read more information here.](/docs/components/liquid)
<% end %>

## Use Bridgetown::Component for Template Rendering

By subclassing `Bridgetown::Component`, you gain [the ability to write a template](/docs/template-engines/erb-and-beyond) in ERB, Serbea, or Streamlined.

For template engines like ERB, add a template file right next to the component's `.rb` file. The template will automatically get rendered by the component (and you won't need to define a `render_in` method yourself). For example, using ERB:

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

Here's the same example using Serbea template syntax:

```serb
<!-- src/_components/field_component.serb -->
<field-component>
  <label>{{ @label }}</label>
  <input type="{{ @type }}" name="{{ @name }}" />
</field-component>
```

Rendering out the component in a parent template and passing along arguments looks like this:

```erb
<%%= render FieldComponent.new(type: "email", name: "email_address", label: "Email Address") %>

  output:
  <field-component>
    <label>Email Address</label>
    <input type="email" name="email_address" />
  </field-component>
```

You can use Ruby's "squiggly heredoc" syntax as a template language with our Streamlined template engine:

```ruby
class FieldComponent
  attr_reader :type, :name, :label

  def initialize(type: "text", name:, label:)
    @type, @name, @label = type, name, label
  end

  def template
    html -> { <<~HTML
      <field-component>
        <label>#{text -> { label }}</label>
        <input #{html_attributes(type:, name:)} />
      </field-component>
    HTML
    }
  end
end
```

Streamlined adds some special helpers so that writing properly-escaped HTML as well as rendering out a hash as attributes or looping through an array is much easier than with plain heredoc syntax. We've found that for complex interplay between Ruby & HTML code, Streamlined is easier to deal with than either ERB or Serbea.

[Read more about how to use Ruby template syntax here.](/docs/template-engines/erb-and-beyond)

<%= render Note.new do %>
Need to add component compatibility with Rails projects? [Try our experimental ViewComponent shim](/docs/components/view-component).
<% end %>

### Content

Bridgetown components are provided access to a `content` variable which is the output of the block passed into the component via the parent `render`:

```erb
<!-- some page template -->
<%%= render(Layout::Box.new(border: :large)) do %>
  I'm in a box!
<%% end %>

<!-- src/_components/layout/box.erb -->
<layout-box border="<%%= @border %>">
  <%%= content %> <!-- I'm in a box! -->
</layout-box>
```

### Slotted Content

New in Bridgetown 1.2, you can now provide specific named content from within the calling template to a component. If the `content` variable above could be considered the "default" slot, you'll now learn how to work with named content slots.

Here's an example of supplying and rendering an image within a card.

```ruby
# src/_components/card.rb
class Card < Bridgetown::Component
  def initialize(title:, footer:)
    @title, @footer = title, footer
  end
end
```

```erb
<!-- src/_components/card.erb -->
<app-card>
  <figure><%%= slotted :image %></figure>
  <header><%%= @title %></header>
  <app-card-inner>
    <%%= content %>
  </app-card-inner>
  <footer><%%= @footer %></footer>
</app-card>
```

```erb
<!-- some page template -->
<%%= render(Card.new(title: "Card Header", footer: "Card Footer")) do |card| %>
  <%% card.slot :image do %><img src="<%%= resource.data.image %>" /><%% end %>

  Some card content goes here!
<%% end %>
```

The `slotted` helper can also provide default content should the slot not already be defined:

```erb
<%%= slotted :image do %>
  <img src="/images/unknown.png" />
<%% end %>
```

Multiple captures using the same slot name will be cumulative. The above `image` slot could be appended to by calling `slot :image` multiple times. If you wish to change this behavior, you can pass `replace: true` as a keyword argument to `slot` to clear any previous slot content. _Use with extreme caution!_

For more control over slot content, you can use the `pre_render` hook. Builders can register hooks to transform slots in specific ways based on their name or context. This is perhaps not all that useful when you're writing both the content and the components, but for customization of third-party components it could come in handy.

```rb
class Builders::FigureItOut < SiteBuilder
  def build
    hook :slots, :pre_render do |slot|
      return unless slot.name == "image" && slot.context == SomeComponent

      slot.content = "#{slot.content}<figcaption>Cool Image</figcaption>".html_safe
    end
  end
end
```

<%= render Note.new do %>
  Both `slot` and `slotted` accept an argument instead of a block for content. So you could call `<%% slot :slotname, "Here's some content" %>` rather than supplying a block.
<% end %>

<%= render Note.new do %>
  Bridgetown's main [Ruby template rendering pipeline](/docs/template-engines/erb-and-beyond#slotted-content) also has its own slotting mechanism.
<% end %>

<%= render Note.new(type: :warning) do %>
  Don't let the naming fool you…Bridgetown's slotted content feature is not related to the concept of slots in custom elements and shadow DOM (aka web components). But there are some surface-level similarities. Many view-related frameworks provide some notion of slots (perhaps called something else like content or layout blocks), as it's helpful to be able to render named "child" content within "parent" views.
<% end %>

## Helpers

As expected, helpers are available as well exactly like in standard templates:

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

## Lifecycle

In addition to rendering a template for you, `Bridgetown::Component` provides a couple lifecycle hooks:

* `render?` – if you define this method and return `false`, the component will not get rendered at all.
* `before_render` – called right before the component is rendered when the view_context is known and all helpers available.

## Sidecar JS/CSS Assets

Some of the components you write will comprise more than pure markup. You may want to affect the styling and behavior of a component as well. For a conceptual overview of this architecture, [read our Components introduction](/docs/components#the-subtle-interplay-of-html-css--javascript).

The easiest way to write frontend component code using "vanilla" web APIs is to wrap your component in a custom element. You can then apply CSS directly to that component from a stylesheet, and even add interactivity via JavaScript.

==TODO: add HTML/CSS/JS example here==

For another spin on this, check out our [Lit Components](/docs/components/lit) documentation. You can also read up on how Bridgetown's [frontend build pipeline works](/docs/frontend-assets).




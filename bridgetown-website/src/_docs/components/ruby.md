---
title: Ruby Components
template_engine: erb
category: components
top_section: Designing Your Site
order: 0
---

A component is a reusable piece of template logic that can be included in any part of the site, and a full suite of components can comprise what is often called a "design system". You can render Ruby component objects directly in your Ruby-based templates, and you can render components from within other components. This provides the basis for a fully-featured view component architecture for ERB and beyond.

Ruby components can be combined with front-end component strategies using **web components** or other JavaScript libraries/frameworks. For one particular spin on this, check out our [Lit Components](/docs/components/lit) documentation.

<%= toc %>

## Basic Building Blocks

Bridgetown automatically loads `.rb` files you add to the `src/_components` folder, so that's likely where you'll want to save your component class definitions. It also load components from plugins which provide a `components` source manifest. Bridgetown's component loader is based on [Zeitwerk](https://github.com/fxn/zeitwerk), so you'll need to make sure your class names and namespaces line up with your component folder hierarchy (e.g., `_components/shared/navbar.rb` should define `Shared::Navbar`.).

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

<%= render Note.new type: "warning" do %>
Bear in mind that Ruby components aren't accessible from Liquid templates. So if you need a component which can be used in either templating system, consider writing a Liquid component. [Read more information here.](/docs/components/liquid)
<% end %>

## Use Bridgetown::Component for Advanced Component Templates

While squggly heredocs are nice, what most people probably want to [the ability to write a template](/docs/templates/erb-and-beyond) in ERB, Haml, Slim, or Serbea.

You can subclass your components from `Bridgetown::Component` and then add a template file right next to the component's `.rb` file. The template will automatically get rendered by the component and you won't need to define a `render_in` method yourself. For example, if we were to translate the previous heredoc to a template-based component:

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

## Need Compatibility with Rails? Try ViewComponent (experimental)

If you've used GitHub's [ViewComponent](https://viewcomponent.org) in the past, you might be thinking by now that `Bridgetown::Component` feels an awful lot like `ViewComponent::Base`. And you're right! We've _intentionally_ modeled our component class off of what we think is one of the most exciting developments in Ruby on Rails view technology in a decade.

But we didn't stop there. Besides being able to use `Brigetown::Component` in your Bridgetown sites, you can actually use ViewComponent itself! How is this even possible?!

By creating a compatibility shim which "fools" ViewComponent into thinking it's booted up in a Rails app when it's actually not. ViewComponent itself is mainly only reliant on the ActionView framework within Rails, so we include that along with the shim, and then you're off to the races. (Note: this functionality is still considered _experimental_.)

Let's break it down!

### Quick Tutorial

First, you'll need to add the compatibility gem to your Gemfile (which will also add in ViewComponent as a dependency). In a new Bridgetown site folder, run the following command:

```
bundle add bridgetown-view-component -g bridgetown_plugins
```

Next create a `shared` folder in `src/_components` and add the following two files:

```ruby
# src/_components/shared/header.rb
module Shared
  class Header < ViewComponent::Base
    include Bridgetown::ViewComponentHelpers

    def initialize(title:, description:)
      @title, @description = title, description
    end
  end
end
```

```erb
<!-- src/_components/shared/header.erb -->
<header style="text-align:center; color: teal">
  <h1 style="color: darkgreen"><%%= @title %></h1>

  <%%= markdownify @description %>
</header>
```

Now let's set up a new layout to render our component. Add `src/_layouts/vc.erb`:

```erb
---
layout: default
---

<%%= render(Shared::Header.new(
      title: resource.data.title,
      description: resource.data.description
    )) %>

<%%= yield %>
```

Finally, update your home page (`src/index.md`) like so:

```md
---
layout: vc
title: ViewComponent
description: It's _here_ and it **works**!
---

Yay! 😃
```

Now run `yarn start`, load your website at localhost:4000, and you should see the new homepage with the `Shared::Header` ViewComponent rendered into the layout!

### Helpers

So far, pretty standard fare for ViewComponent, but you'll notice we had to add `include Bridgetown::ViewComponentHelpers` to the definition of our `Shared::Header` class. That's because, out of the box, ViewComponent doesn't know about any of Bridgetown's helpers. We could have injected helpers directly into the base class, but that might adversely affect components written with Rails in mind, so at least in this early phase we're including the module manually.

<%= render Note.new do %>
As a shortcut, you could create your own base class, say `SiteViewComponent`, which inherits from `ViewComponent::Base`, include the `Bridgetown::ViewComponentHelpers` module, and then subclass all your site components from `SiteViewComponent`.
<% end %>

### Rails Helpers

Including `Bridgetown::ViewComponentHelpers` in a ViewComponent provides access to Bridgetown helpers within the component. However, to facilitate that, most of the default [Action View Helpers](https://guides.rubyonrails.org/action_view_helpers.html) get disabled, since many helpers rely on Rails and will not work with Bridgetown.

`Bridgetown::ViewComponentHelpers#allow_rails_helpers` provides an API to enable supplied Action View Helpers like `ActionView::Helpers::TagHelper`:

```ruby
class HeaderComponent < ViewComponent::Base
  Bridgetown::ViewComponentHelpers.allow_rails_helpers :tag

  def call
    tag.h1 content, class: "my-8 text-3xl font-bold tracking-tight text-primary-white sm:text-4xl"
  end
end
```

In this example, `Bridgetown::ViewComponentHelpers.allow_rails_helpers :tag` enables `ActionView::Helpers::TagHelper`. We can create an inline ViewComponent that leverages `tag.h1` to create an `<h1>` element with our supplied content.

In your template, `<%%= render HeaderComponent.new.with_content("👋") %>` would output:

```html
<h1 class="my-8 text-3xl font-bold tracking-tight text-primary-white sm:text-4xl">👋</h1>
```

Like helpers, you can include `Bridgetown::ViewComponentHelpers.allow_rails_helpers :tag` in a base class that your components inherit from to reduce duplication.

### Using Primer

[Primer](https://primer.style) is a component library and design system published by GitHub, and you can use it now with Bridgetown! However, you'll need to do a bit of extra "shim" work to get Primer view components loaded within the Bridgetown context.

First, add the following to your Gemfile:

```ruby
gem "railties" # required by Primer
gem "actionpack" # required by Primer
gem "primer_view_components"
```

Next, add the following file to your plugins folder:

```ruby
# plugins/builders/primer_builder.rb

require "action_dispatch"
require "rails/engine"
require "primer/view_components/engine"

class Builders::PrimerBuilder < SiteBuilder
  def build
    site.config.loaded_primer ||= begin
      primer_loader = Zeitwerk::Loader.new
      Primer::ViewComponents::Engine.config.eager_load_paths.each do |path|
        primer_loader.push_dir path
      end
      primer_loader.setup
      Rails.application.config = Primer::ViewComponents::Engine.config
      true
    end
  end
end
```

What this does is import a couple of additional Rails dependencies, set up the autoloading functionality provided by Zeitwerk, and ensure Primer's engine config is added to the Rails shim. We also want to guarantee this code only runs once when in Bridgetown's watch mode.

Let's also add the Primer CSS link tag to your site's head:

```
<link href="https://unpkg.com/@primer/css@^19.0.0/dist/primer.css" rel="stylesheet" />
```

Now you can use Primer components in any Ruby template in your Bridgetown project!

```erb
<%%= render(Primer::FlashComponent.new(scheme: :success)) do %>
  <span markdown="1">This is a **success** flash message!</span>
<%% end %>
```

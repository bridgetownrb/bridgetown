---
title: ViewComponent (Rails Compatibility Layer)
template_engine: erb
category: components
top_section: Designing Your Site
order: 0
---

If you've used GitHub's [ViewComponent](https://viewcomponent.org) on existing Rails projects, you're in luck! We've created a compatibility shim which "fools" ViewComponent into thinking it's booted up in a Rails app when it's actually not. ViewComponent itself is mainly only reliant on the ActionView framework within Rails, so we include that along with the shim, and then you're off to the races. (Note: this functionality is still considered _experimental_.)

Let's break it down.

## Quick Tutorial

First, you'll need to add the plugin to your Gemfile. In a Bridgetown project folder, run the following command:

```
bundle add bridgetown-view-component
```

and then add `init :"bridgetown-view-component"` to `config/initializers.rb`.

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

Now run `bin/bridgetown start`, load your website at localhost:4000, and you should see the new homepage with the `Shared::Header` ViewComponent rendered into the layout!

## Helpers

So far, pretty standard fare for ViewComponent, but you'll notice we had to add `include Bridgetown::ViewComponentHelpers` to the definition of our `Shared::Header` class. That's because, out of the box, ViewComponent doesn't know about any of Bridgetown's helpers. We could have injected helpers directly into the base class, but that might adversely affect components written with Rails in mind, so at least in this early phase we're including the module manually.

<%= render Note.new do %>
As a shortcut, you could create your own base class, say `SiteViewComponent`, which inherits from `ViewComponent::Base`, include the `Bridgetown::ViewComponentHelpers` module, and then subclass all your site components from `SiteViewComponent`.
<% end %>

## Rails Helpers

Including `Bridgetown::ViewComponentHelpers` in a ViewComponent provides access to Bridgetown helpers within the component. However, to facilitate that, most of the default [Action View Helpers](https://guides.rubyonrails.org/action_view_helpers.html) get disabled, since many helpers rely on Rails and will not work with Bridgetown.

`Bridgetown::ViewComponentHelpers#allow_rails_helpers` provides an API to enable supplied Action View Helpers like `ActionView::Helpers::TagHelper`:

```ruby
class HeaderComponent < ViewComponent::Base
  Bridgetown::ViewComponentHelpers.allow_rails_helpers :tag
  include Bridgetown::ViewComponentHelpers

  def call
    tag.h1 content, class: "my-8 text-3xl font-bold tracking-tight text-primary-white sm:text-4xl"
  end
end
```
<%= render Note.new do %>
The Rails helpers must be included _before_ the Bridgetown View Component helpers, as shown in this example.
<% end %>

In this example, `Bridgetown::ViewComponentHelpers.allow_rails_helpers :tag` enables `ActionView::Helpers::TagHelper`. We can create an inline ViewComponent that leverages `tag.h1` to create an `<h1>` element with our supplied content.

In your template, `<%%= render HeaderComponent.new.with_content("👋") %>` would output:

```html
<h1 class="my-8 text-3xl font-bold tracking-tight text-primary-white sm:text-4xl">👋</h1>
```

Like helpers, you can include `Bridgetown::ViewComponentHelpers.allow_rails_helpers :tag` in a base class that your components inherit from to reduce duplication.

## Using Primer

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

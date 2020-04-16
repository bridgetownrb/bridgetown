---
title: Tags
hide_in_toc: true
order: 0
category: plugins
---

{% include help_needed.md %}

If you’d like to include custom [Liquid](/docs/liquid/) tags in your site, you can do so by
hooking into the tagging system with simple Ruby objects. Built-in examples added by Bridgetown include the
`post_url` and `include` tags. Below is an example of a custom Liquid tag that
will output the time the page was rendered:

```ruby
module MySite
  class RenderTimeTag < Liquid::Tag

    def initialize(tag_name, text, tokens)
      super
      @text = text
    end

    def render(context)
      "#{@text} #{Time.now}"
    end
  end
end

Liquid::Template.register_tag('render_time', MySite::RenderTimeTag)
```

At a minimum, Liquid tags must implement:

<table class="settings biggest-output">
  <thead>
    <tr>
      <th>Method</th>
      <th>Description</th>
    </tr>
  </thead>
  <tbody>
    <tr>
      <td>
        <p><code>render</code></p>
      </td>
      <td>
        <p>Outputs the content of the tag.</p>
      </td>
    </tr>
  </tbody>
</table>

You must also register the custom tag with the Liquid template engine as
follows:

```ruby
Liquid::Template.register_tag('render_time', MySite::RenderTimeTag)
```

In the example above, we can place the following tag anywhere in one of our
pages:

{% raw %}
```liquid
<p>{% render_time page rendered at: %}</p>
```
{% endraw %}

And we would get something like this on the page:

```html
<p>page rendered at: Tue June 22 23:38:47 –0500 2010</p>
```

## Tag Blocks

The `render_time` tag seen above can also be rewritten as a tag block by
inheriting the `Liquid::Block` class. Look at the example below:

```ruby
module MySite
  class RenderTimeTagBlock < Liquid::Block

    def render(context)
      text = super
      "<p>#{text} #{Time.now}</p>"
    end

  end
end

Liquid::Template.register_tag('render_time', MySite::RenderTimeTagBlock)
```

We can now use the tag block anywhere:

{% raw %}
```liquid
{% render_time %}
page rendered at:
{% endrender_time %}
```
{% endraw %}

And we would still get the same output as above on the page:

```html
<p>page rendered at: Tue June 22 23:38:47 –0500 2010</p>
```

{: .note .info}
In the above example, the tag block and the tag are both registered with
the name <code>render_time</code>, but you'll want to avoid registering a tag and a tag block using the same name in the same project as this will lead to conflicts.

<div class="note">
  <h5>Top Tip: Access the site object using Liquid</h5>
  <p>
    Bridgetown lets you access the <code>site</code> object through the
    <code>context.registers</code> feature of Liquid at <code>context.registers[:site]</code>. For example, you can
    access the global configuration file <code>bridgetown.config.yml</code> using
    <code>context.registers[:site].config</code>.
  </p>
</div>

---
title: Hooks
hide_in_toc: true
order: 0
category: plugins
---

Using hooks, your plugin can exercise fine-grained control over various aspects
of the build process. If your plugin defines any hooks, Bridgetown will call them
at pre-defined points.

Hooks are registered to a container and an event name. To register one, you
call Bridgetown::Hooks.register, and pass the container, event name, and code to
call whenever the hook is triggered. For example, if you want to execute some
custom functionality every time Bridgetown renders a post, you could register a
hook like this:

```ruby
# Builder API
def build
  hook :posts, :post_render do |post|
    # code to call after Bridgetown renders a post
  end
end
```

```ruby
# Legacy API
Bridgetown::Hooks.register :posts, :post_render do |post|
  # code to call after Bridgetown renders a post
end
```

Be aware that the `build` method of the Builder API is called during the `pre_read` site event, so you won't be able to write a hook for any earlier events (`after_init` for example). In those cases, you will still need to use the Legacy API.

Bridgetown provides hooks for <code>:site</code>, <code>:pages</code>,
<code>:posts</code>, <code>:documents</code> and <code>:clean</code>. In all
cases, Bridgetown calls your hooks with the container object as the first callback
parameter. All `:pre_render` hooks and the`:site, :post_render` hook will also
provide a payload hash as a second parameter. In the case of `:pre_render`, the
payload gives you full control over the variables that are available while
rendering. In the case of `:site, :post_render`, the payload contains final
values after rendering all the site (useful for sitemaps, feeds, etc).

## Priorities

Hooks can be registered with a priority of high, normal, or low, and are run according to that order. The default priority is normal. To register with a different priority other than normal:

```ruby
# Builder API
def build
  hook :posts, :post_render, priority: :high do |post|
    # High priority code to call after Bridgetown renders a post
  end
end
```

```ruby
# Legacy API
Bridgetown::Hooks.register :posts, :post_render, priority: :low do |post|
  # Low priority code to call after Bridgetown renders a post
end
```

## Reloadable vs. Non-Reloadable Hooks

Starting with Bridgetown 0.14, all hooks are cleared during **watch** mode (aka `bridgetown build -w` or `bridgetown serve`) whenever plugin or content files are updated. This makes sense for plugins that are part of the site repository and are therefore reloaded automatically.

However, for gem-based plugins, you will want to make sure you define your hooks as _non-reloadable_, otherwise your hooks will vanish any time the site is updated during watch mode.

```ruby
def build
  hook :site, :post_read, reloadable: false do |post|
    # do something with site data after it's read from disk
  end
end
```

## Complete List of Hooks

<table class="settings biggest-output">
  <thead>
    <tr>
      <th>Container</th>
      <th>Event</th>
      <th>Called</th>
    </tr>
  </thead>
  <tbody>
    <tr>
      <td>
        <p><code>:site</code></p>
      </td>
      <td>
        <p><code>:after_init</code></p>
      </td>
      <td>
        <p>Just after the site initializes, but before setup & render. Good
        for modifying the configuration of the site.</p>
      </td>
    </tr>
    <tr>
      <td>
        <p><code>:site</code></p>
      </td>
      <td>
        <p><code>:after_reset</code></p>
      </td>
      <td>
        <p>Just after site reset (all internal data structures are in a pristine state)</p>
      </td>
    </tr>
    <tr>
      <td>
        <p><code>:site</code></p>
      </td>
      <td>
        <p><code>:pre_read</code></p>
      </td>
      <td>
        <p>After site reset/setup when all custom plugins, generators, etc. have loaded</p>
      </td>
    </tr>
    <tr>
      <td>
        <p><code>:site</code></p>
      </td>
      <td>
        <p><code>:post_read</code></p>
      </td>
      <td>
        <p>After site data has been read and loaded from disk</p>
      </td>
    </tr>
    <tr>
      <td>
        <p><code>:site</code></p>
      </td>
      <td>
        <p><code>:pre_render</code></p>
      </td>
      <td>
        <p>Just before rendering the whole site</p>
      </td>
    </tr>
    <tr>
      <td>
        <p><code>:site</code></p>
      </td>
      <td>
        <p><code>:post_render</code></p>
      </td>
      <td>
        <p>After rendering the whole site, but before writing any files</p>
      </td>
    </tr>
    <tr>
      <td>
        <p><code>:site</code></p>
      </td>
      <td>
        <p><code>:post_write</code></p>
      </td>
      <td>
        <p>After writing the whole site to disk</p>
      </td>
    </tr>
    <tr>
      <td>
        <p><code>:pages</code></p>
      </td>
      <td>
        <p><code>:post_init</code></p>
      </td>
      <td>
        <p>Whenever a page is initialized</p>
      </td>
    </tr>
    <tr>
      <td>
        <p><code>:pages</code></p>
      </td>
      <td>
        <p><code>:pre_render</code></p>
      </td>
      <td>
        <p>Just before rendering a page</p>
      </td>
    </tr>
    <tr>
      <td>
        <p><code>:pages</code></p>
      </td>
      <td>
        <p><code>:post_render</code></p>
      </td>
      <td>
        <p>After rendering a page, but before writing it to disk</p>
      </td>
    </tr>
    <tr>
      <td>
        <p><code>:pages</code></p>
      </td>
      <td>
        <p><code>:post_write</code></p>
      </td>
      <td>
        <p>After writing a page to disk</p>
      </td>
    </tr>
    <tr>
      <td>
        <p><code>:posts</code></p>
      </td>
      <td>
        <p><code>:post_init</code></p>
      </td>
      <td>
        <p>Whenever a post is initialized</p>
      </td>
    </tr>
    <tr>
      <td>
        <p><code>:posts</code></p>
      </td>
      <td>
        <p><code>:pre_render</code></p>
      </td>
      <td>
        <p>Just before rendering a post</p>
      </td>
    </tr>
    <tr>
      <td>
        <p><code>:posts</code></p>
      </td>
      <td>
        <p><code>:post_render</code></p>
      </td>
      <td>
        <p>After rendering a post, but before writing it to disk</p>
      </td>
    </tr>
    <tr>
      <td>
        <p><code>:posts</code></p>
      </td>
      <td>
        <p><code>:post_write</code></p>
      </td>
      <td>
        <p>After writing a post to disk</p>
      </td>
    </tr>
    <tr>
      <td>
        <p><code>:documents</code></p>
      </td>
      <td>
        <p><code>:post_init</code></p>
      </td>
      <td>
        <p>Whenever a document is initialized</p>
      </td>
    </tr>
    <tr>
      <td>
        <p><code>:documents</code></p>
      </td>
      <td>
        <p><code>:pre_render</code></p>
      </td>
      <td>
        <p>Just before rendering a document</p>
      </td>
    </tr>
    <tr>
      <td>
        <p><code>:documents</code></p>
      </td>
      <td>
        <p><code>:post_render</code></p>
      </td>
      <td>
        <p>After rendering a document, but before writing it to disk</p>
      </td>
    </tr>
    <tr>
      <td>
        <p><code>:documents</code></p>
      </td>
      <td>
        <p><code>:post_write</code></p>
      </td>
      <td>
        <p>After writing a document to disk</p>
      </td>
    </tr>
    <tr>
      <td>
        <p><code>:clean</code></p>
      </td>
      <td>
        <p><code>:on_obsolete</code></p>
      </td>
      <td>
        <p>During the cleanup of a site's destination before it is built</p>
      </td>
    </tr>
  </tbody>
</table>

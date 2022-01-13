---
title: Hooks
order: 0
top_section: Configuration
category: plugins
---

Using hooks, your plugin can exercise fine-grained control over various aspects
of the build process. If your plugin defines any hooks, Bridgetown will call them
at pre-defined points.

Hooks are registered to an owner and an event name. For example, if you want to execute some
custom functionality every time Bridgetown renders a post, you could register a
hook like this:

```ruby
# Builder API:
def build
  hook :posts, :post_render do |post|
    # code to call after Bridgetown renders a post
  end
end

# or using the hooks API directly:
Bridgetown::Hooks.register_one :posts, :post_render do |post|
  # code to call after Bridgetown renders a post
end
```

Be aware that the `build` method of the Builder API is called during the `pre_read` site event, so you won't be able to write a hook for any earlier events (`after_init` for example). In those cases, you will still need to use the hooks API directly.

Bridgetown provides hooks for `:site`, `:resources`, `:loader`, `:clean`, and `:[collection_label]` (aka every collection gets a unique hook, such as `posts` or `countries` or `episodes`, etc.).

In all cases, Bridgetown calls your hooks with the owner object as the first callback
parameter.

## Post-Write Hook for Performing Special Operations

The `:site, :post_write` hook is particularly useful in that you can use it to
kick off additional operations which need to happen after the site has been 
completely built and everything has been saved to the destination folder.

For example, there might be certain files you want to compress, or maybe you
need to notify an external web service about new updates, or perhaps you'd like
to [run tests against the final output](/docs/testing).

## Priorities

Hooks can be registered with a priority of high, normal, or low, and are run according to that order. The default priority is normal. To register with a different priority other than normal:

```ruby
# Builder API
def build
  hook :posts, :post_render, priority: :high do |post|
    # High priority code to call after Bridgetown renders a post
  end
end

Bridgetown::Hooks.register_one :posts, :post_render, priority: :low do |post|
  # Low priority code to call after Bridgetown renders a post
end
```

## Reloadable vs. Non-Reloadable Hooks

All hooks are cleared during **watch** mode (aka `bridgetown build -w` or `bridgetown start`) whenever plugin or content files are updated. This makes sense for plugins that are part of the site repository and are therefore reloaded automatically.

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
      <th>Owner</th>
      <th style="width:25%">Event</th>
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
        <p>Just after site reset and all internal data structures are in a pristine state. Not run during SSR (see below).</p>
      </td>
    </tr>
    <tr>
      <td>
        <p><code>:site</code></p>
      </td>
      <td>
        <p><code>:after_soft_reset</code></p>
      </td>
      <td>
        <p>When a site is in SSR mode, any file changes result in a "soft" reset for performance reasons. Some state is persisted across resets. You can register a hook to perform additional cleanup/setup after a soft reset.</p>
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
        <p><code>:site</code></p>
      </td>
      <td>
        <p><code>:pre_reload</code></p>
      </td>
      <td>
        <p>Just before reloading site plugins and Zeitwerk autoloaders during the watch process or in the console</p>
      </td>
    </tr>
    <tr>
      <td>
        <p><code>:site</code></p>
      </td>
      <td>
        <p><code>:post_reload</code></p>
      </td>
      <td>
        <p>After reloading site plugins and Zeitwerk autoloaders during the watch process or in the console</p>
      </td>
    </tr>
    <tr>
      <td>
        <p><code>:resources</code><br/><code>[collection_label]</code></p>
      </td>
      <td>
        <p><code>:post_init</code></p>
      </td>
      <td>
        <p>Whenever a resource is initialized</p>
      </td>
    </tr>
    <tr>
      <td>
        <p><code>:resources</code><br/><code>[collection_label]</code></p>
      </td>
      <td>
        <p><code>:post_read</code></p>
      </td>
      <td>
        <p>Whenever a resource has read all of its data from the origin model, but before rendering/transformation</p>
      </td>
    </tr>
    <tr>
      <td>
        <p><code>:resources</code><br/><code>[collection_label]</code></p>
      </td>
      <td>
        <p><code>:pre_render</code></p>
      </td>
      <td>
        <p>Just before rendering a resource</p>
      </td>
    </tr>
    <tr>
      <td>
        <p><code>:resources</code><br/><code>[collection_label]</code></p>
      </td>
      <td>
        <p><code>:post_render</code></p>
      </td>
      <td>
        <p>After rendering a resource, but before writing it to disk</p>
      </td>
    </tr>
    <tr>
      <td>
        <p><code>:resources</code><br/><code>[collection_label]</code></p>
      </td>
      <td>
        <p><code>:post_write</code></p>
      </td>
      <td>
        <p>After writing a resource to disk</p>
      </td>
    </tr>
    <tr>
      <td>
        <p><code>:generated_pages</code></p>
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
        <p><code>:generated_pages</code></p>
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
        <p><code>:generated_pages</code></p>
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
        <p><code>:generated_pages</code></p>
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
        <p><code>:loader</code></p>
      </td>
      <td>
        <p><code>:pre_setup</code></p>
      </td>
      <td>
        <p>Before initial setup of a Zeitwerk autoloader. The `loader` object and `load_path` are provided as arguments.</p>
      </td>
    </tr>
    <tr>
      <td>
        <p><code>:loader</code></p>
      </td>
      <td>
        <p><code>:post_setup</code></p>
      </td>
      <td>
        <p>After initial setup of a Zeitwerk autoloader. The `loader` object and `load_path` are provided as arguments.</p>
      </td>
    </tr>
    <tr>
      <td>
        <p><code>:loader</code></p>
      </td>
      <td>
        <p><code>:pre_reload</code></p>
      </td>
      <td>
        <p>Before a Zeitwerk autoloader reloads all code under its supervision. The `loader` object and `load_path` are provided as arguments.</p>
      </td>
    </tr>
    <tr>
      <td>
        <p><code>:loader</code></p>
      </td>
      <td>
        <p><code>:post_reload</code></p>
      </td>
      <td>
        <p>After a Zeitwerk autoloader reloads all code under its supervision. The `loader` object and `load_path` are provided as arguments.</p>
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

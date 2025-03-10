---
title: Collections
order: 100
top_section: Writing Content
category: collections
---

Collections are the perfect way to group [resource-based content](/docs/resources), such as blog posts, team members, talks at a conference, products to sell, upcoming events, and so forth. Bridgetown comes with a few built-in collections, and you can add new collections to support all sorts of content structures and hierarchies. All of the documentation pages on this very website are contained within a `docs` collection for example.

Let's dive into how you can put collections to work for your content.

{{ toc }}

## Builtin Collections

Bridgetown comes with three collections configured out of the box. These are

* `data`, located in the `src/_data` folder
* `pages`, located in either the `src` top-level folder or the `src/_pages` folder
* `posts`, located in the `src/_posts` folder

The data collection doesn't output to any URL and is used strictly to provide a complete merged dataset via the `site.data` variable. [Learn more about data files here.](/docs/datafiles)

Pages are for generic, standalone (aka not dated) pages which will output at a URL similar to their file path. So `src/i/am/a-page.html` will end up with the URL `/i/am/a-page/`.

Posts are for dated articles which will output at a URL based on the configured permalink style which might include category and date information. Posts are typically saved in a `YYYY-MM-DD-slug-goes-here.EXT` format which will cause the date to be extracted from the filename prefix. Posts can be saved in an arbitrary folder structure that makes the most sense for your content (as long as they're contained within `src/_posts`).

## Custom Collections

You're by no means limited to the builtin collections. You can create custom collections with any name you choose. By default they will behave similar to standalone pages, but you can configure them to behave in other ways (maybe like posts). For example, you could create an events collection which would function similar to posts, and you could even allow future-dated content to publish (unlike what's typical for posts).

{%@ Documentation::Multilang do %}
```ruby
# config/initializers.rb
Bridgetown.configure do
  collections do
    events do
      output true
      permalink "pretty"
      future true
    end
  end
end
```
===
```yaml
# bridgetown.config.yml
collections:
  events:
    output: true
    permalink: pretty
    future: true
```
{% end %}

Thus an event saved at `src/_events/2021-12-15-merry-christmas.md` would output to the URL `/events/2021/12/15/merry-christmas/`.

You can control the way a collection is sorted by specifying the [front matter](/docs/front-matter) key (default is either filename or date if present) as well as the direction as either ascending (default) or descending.

{%@ Documentation::Multilang do %}
```ruby
# config/initializers.rb
Bridgetown.configure do
  collections do
    reverse_ordered do
      output true
      sort_by "order"
      sort_direction "descending"
    end
  end
end
```
===
```yaml
# bridgetown.config.yml
collections:
  reverse_ordered:
    output: true
    sort_by: order
    sort_direction: descending
```
{% end %}

## Adding Content

When setting up a custom collection, you'll want to create a corresponding folder (e.g. `src/_staff_members`) and then add your resource files (aka files which include [front matter](/docs/front-matter)). If no front
matter is provided in a file, Bridgetown will consider it to be a [static file](/docs/static-files/)
and the contents will not undergo further processing. Otherwise, Bridgetown will process the file contents into the expected output.

Regardless of whether front matter exists or not, Bridgetown will write to the destination folder (e.g. `output`) only if `output: true` has been set in the collection's metadata.

{%@ Note type: :warning do %}
  #### Be sure to name your folders correctly

  The folder must be named identically to the collection you defined in the configuration with the addition of the `_` prefix.
{% end %}

## Accessing Collection Content

Bridgetown provides the `collections` object to your templates, with the various collections available as keys. For example, you can iterate over `staff_members` resources on a page and display the content for each staff member. The main body of the resource is accessed using the `content` variable:

{%@ Documentation::Multilang do %}
```erb
<% collections.staff_members.each do |staff_member| %>
  <h2><%= staff_member.data.name %> - <%= staff_member.data.position %></h2>
  <p><%= markdownify staff_member.content %></p>
<% end %>
```
===
{% raw %}
```liquid
{% for staff_member in collections.staff_members.resources %}
  <h2>{{ staff_member.data.name }} - {{ staff_member.data.position }}</h2>
  <p>{{ staff_member.content | markdownify }}</p>
{% endfor %}
```
{% endraw %}
{% end %}

## Output

If you'd like Bridgetown to create a rendered page for each resource in your collection, make sure the `output` key is set to `true` in your collection metadata:

{%@ Documentation::Multilang do %}
```ruby
# config/initializers.rb
Bridgetown.configure do
  collections do
    staff_members do
      output true
    end
  end
end
```
===
```yaml
# bridgetown.config.yml
collections:
  staff_members:
    output: true
```
{% end %}

You can link to the generated resource using the `relative_url` attribute.

{%@ Documentation::Multilang do %}
```erb
<% staff_member = collections.staff_members.first %>

<a href="<%= staff_member.relative_url %>">
  <%= staff_member.data.name %> - <%= staff_member.data.position %>
</a>
```
===
{% raw %}
```liquid
{% assign staff_member = collections.staff_members.resources[0] %}

<a href="{{ staff_member.relative_url }}">
  {{ staff_member.name }} - {{ staff_member.position }}
</a>
```
{% endraw %}
{% end %}

{%@ Note do %}
If you have a large number of resources in a collection, it's likely you'll want to use the [Pagination feature](/docs/content/pagination) to make it easy to browse through a limited number of items per page.
{% end %}

### Permalinks

There are special [permalink variables for collections](/docs/content/permalinks) to help you control the output URL for the collection. Each collection can be configured with its own permalink style. Of course you're always welcome to override that permalink on a individual resource-by-resource basis, or by using [front matter defaults](/docs/content/front-matter-defaults).

## Custom Metadata

It's also possible to add custom metadata to a collection. You add
additional keys to the collection config and they'll be made available in templates. For example, if you specify this:

{%@ Documentation::Multilang do %}
```ruby
# config/initializers.rb
Bridgetown.configure do
  collections do
    tutorials do
      output true
      name "Terrific Tutorials"
    end
  end
end
```
===
```yaml
# bridgetown.config.yml
collections:
  tutorials:
    output: true
    name: Terrific Tutorials
```
{% end %}

Then you could access the `name` value in a template by referencing the collection directly or through a resource:

{%@ Documentation::Multilang do %}
```erb
Direct access to collection:
<%= collections.tutorials.metadata.name %>

Via a resource:
<%= resource.collection.metadata.name %>
```
===
{% raw %}
```liquid
Direct access to collection:
{{ collections.tutorials.name }}

Via a resource:
{{ resource.collection.name }}
```
{% endraw %}
{% end %}

## Collection Attributes

Collection objects are available under `collections` with the following information:

<table class="settings bigger-output">
  <thead>
    <tr>
      <th>Variable</th>
      <th>Description</th>
    </tr>
  </thead>
  <tbody>
    <tr>
      <td>
        <p><code>label</code></p>
      </td>
      <td>
        <p>
          The name of your collection, e.g. <code>my_collection</code>.
        </p>
      </td>
    </tr>
    <tr>
      <td>
        <p><code>resources</code></p>
      </td>
      <td>
        <p>
          An array of resources.
        </p>
      </td>
    </tr>
    <tr>
      <td>
        <p><code>static_files</code> / <code>files</code> (Liquid)</p>
      </td>
      <td>
        <p>
          An array of static files in the collection.
        </p>
      </td>
    </tr>
    <tr>
      <td>
        <p><code>relative_directory</code></p>
      </td>
      <td>
        <p>
          The path to the collection's source folder, relative to the site
          source.
        </p>
      </td>
    </tr>
    <tr>
      <td>
        <p><code>directory</code></p>
      </td>
      <td>
        <p>
          The full path to the collections's source folder.
        </p>
      </td>
    </tr>
    <tr>
      <td>
        <p><code>metadata.output</code> / <code>output</code> (Liquid)</p>
      </td>
      <td>
        <p>
          Whether the collection's documents will be output as individual
          files.
        </p>
      </td>
    </tr>
  </tbody>
</table>

{%@ Note do %}
  #### You can relocate your Collections

  It's possible to optionally specify a folder to store all your collections in a centralized folder with `collections_dir: my_collections`.

  Then Bridgetown will look in `my_collections/_books` for the `books` collection, and
  in `my_collections/_recipes` for the `recipes` collection.
{% end %}

{%@ Note type: "warning" do %}
  #### Be sure to move posts into custom collections folder

  If you specify a folder to store all your collections in the same place with `collections_dir: my_collections`, then you will need to move your `_posts` folder to `my_collections/_posts`. Note that the name of your collections directory cannot start with an underscore (`_`).
{% end %}

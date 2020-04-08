---
title: Collections
order: 13
top_section: Content
category: collections
---

Collections are a great way to group related content like members of a team or
talks at a conference.

## Setup

To use a Collection you first need to define it in your `bridgetown.config.yml`. For
example here's a collection of staff members:

```yaml
collections:
  - staff_members
```

In this case `collections` is defined as a sequence (i.e array) with no additional metadata defined for each collection.
You can optionally specify metadata for your collection by defining `collections` as a mapping (i.e hash) instead of sequence, and then defining additional fields in it:

```yaml
collections:
  staff_members:
    people: true
```

{: .note .info}
When defining a collection as a sequence, its pages will not be rendered by
default. To enable this, <code>output: true</code> must be specified on the
collection, which requires defining the collection as a mapping. For more
information, see the section <a href="#output">Output</a>.

<div class="note">
  <h5>Gather your collections</h5>

  <p>You can optionally specify a folder to store all your collections in the same place with <code>collections_dir: my_collections</code>.</p>

  <p>Then Bridgetown will look in <code>my_collections/_books</code> for the <code>books</code> collection, and
  in <code>my_collections/_recipes</code> for the <code>recipes</code> collection.</p>
</div>

<div class="note warning">
  <h5>Be sure to move posts into custom collections folder</h5>

  <p>If you specify a folder to store all your collections in the same place with <code>collections_dir: my_collections</code>, then you will need to move your <code>_posts</code> folder to <code>my_collections/_posts</code>. Note that, the name of your collections directory cannot start with an underscore (`_`).</p>
</div>

## Add content

Create a corresponding folder (e.g. `<source>/_staff_members`) and add
documents. Front matter is processed if the [front matter](/docs/front-matter/) exists, and everything
after the front matter is pushed into the document's `content` attribute. If no front
matter is provided, Bridgetown will consider it to be a [static file]({{ '/docs/static-files/' | relative_url }})
and the contents will not undergo further processing. If front matter is provided,
Bridgetown will process the file contents into the expected output.

Regardless of whether front matter exists or not, Bridgetown will write to the destination
folder (e.g. `output`) only if `output: true` has been set in the collection's
metadata.

For example here's how you would add a staff member to the collection set above.
The filename is `./_staff_members/jane.md` with the following content:

```markdown
---
name: Jane Doe
position: Developer
---
Jane has worked on Bridgetown for the past *five years*.
```

<div class="note info">
  <h5>Be sure to name your folders correctly</h5>
  <p>
The folder must be named identically to the collection you defined in
your <code>bridgetown.config.yml</code> file, with the addition of the preceding <code>_</code> character.
  </p>
</div>

## Output

Now you can iterate over `site.staff_members` on a page and output the content
for each staff member. Similar to posts, the body of the document is accessed
using the `content` variable:

{% raw %}
```liquid
{% for staff_member in site.staff_members %}
  <h2>{{ staff_member.name }} - {{ staff_member.position }}</h2>
  <p>{{ staff_member.content | markdownify }}</p>
{% endfor %}
```
{% endraw %}

If you'd like Bridgetown to create a rendered page for each document in your
collection, you can set the `output` key to `true` in your collection
metadata in `bridgetown.config.yml`:

```yaml
collections:
  staff_members:
    output: true
```

You can link to the generated page using the `url` attribute:

{% raw %}
```liquid
{% for staff_member in site.staff_members %}
  <h2>
    <a href="{{ staff_member.url }}">
      {{ staff_member.name }} - {{ staff_member.position }}
    </a>
  </h2>
  <p>{{ staff_member.content | markdownify }}</p>
{% endfor %}
```
{% endraw %}

## Permalinks

There are special [permalink variables for collections](/docs/structure/permalinks/) to
help you control the output url for the entire collection.

## Custom Sorting of Documents

By default, multiple documents in a collection are sorted by their `date` attribute when they have the `date` key in their front matter. However, if documents do not have the `date` key in their front matter, they are sorted by their respective paths.

You can control this sorting via the collection's metadata.

### Sort By Front Matter Key

Documents can be sorted based on a front matter key by setting a `sort_by` metadata to the front matter key string. For example,
to sort a collection of tutorials based on key `lesson`, the configuration would be:

```yaml
collections:
  tutorials:
    sort_by: lesson
```

The documents are arranged in the increasing order of the key's value. If a document does not have the front matter key defined
then that document is placed immediately after sorted documents. When multiple documents do not have the front matter key defined,
those documents are sorted by their dates or paths and then placed immediately after the sorted documents.

## Liquid Attributes

### Collections

Collections are also available under `site.collections`, with the metadata
you specified in your `bridgetown.config.yml` (if present) and the following information:

<table>
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
        <p><code>docs</code></p>
      </td>
      <td>
        <p>
          An array of <a href="#documents">documents</a>.
        </p>
      </td>
    </tr>
    <tr>
      <td>
        <p><code>files</code></p>
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
        <p><code>output</code></p>
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

<div class="note info">
  <h5>Posts: a Built-in Collection</h5>
  <p>In addition to any collections you create yourself, the
  <code>posts</code> collection is hard-coded into Bridgetown. It exists whether
  you have a <code>_posts</code> directory or not. This is something to note
  when iterating through <code>site.collections</code> as you may need to
  filter it out.</p>
  <p>You may wish to use filters to find your collection:
  <code>{% raw %}{{ site.collections | where: "label", "myCollection" | first }}{% endraw %}</code></p>
</div>

<div class="note info">
  <h5>Collections and Time</h5>
  <p>Except for documents in hard-coded default collection <code>posts</code>, all documents in collections
    you create, are accessible via Liquid irrespective of their assigned date, if any, and therefore renderable.
  </p>
  <p>Documents are attempted to be written to disk only if the concerned collection
    metadata has <code>output: true</code>. Additionally, future-dated documents are only written if
    <code>site.future</code> <em>is also true</em>.
  </p>
  <p>More fine-grained control over documents being written to disk can be exercised by setting
    <code>published: false</code> (<em><code>true</code> by default</em>) in the document's front matter.
  </p>
</div>

### Documents

In addition to any front matter provided in the document's corresponding
file, each document has the following attributes:

<table>
  <thead>
    <tr>
      <th>Variable</th>
      <th>Description</th>
    </tr>
  </thead>
  <tbody>
    <tr>
      <td>
        <p><code>content</code></p>
      </td>
      <td>
        <p>
          The (unrendered) content of the document. If no front matter is
          provided, Bridgetown will not generate the file in your collection. If
          front matter is used, then this is all the contents of the file
          after the terminating
          `---` of the front matter.
        </p>
      </td>
    </tr>
    <tr>
      <td>
        <p><code>output</code></p>
      </td>
      <td>
        <p>
          The rendered output of the document, based on the
          <code>content</code>.
        </p>
      </td>
    </tr>
    <tr>
      <td>
        <p><code>path</code></p>
      </td>
      <td>
        <p>
          The full path to the document's source file.
        </p>
      </td>
    </tr>
    <tr>
      <td>
        <p><code>relative_path</code></p>
      </td>
      <td>
        <p>
          The path to the document's source file relative to the site source.
        </p>
      </td>
    </tr>
    <tr>
      <td>
        <p><code>url</code></p>
      </td>
      <td>
        <p>
          The URL of the rendered collection. The file is only written to the destination when the collection to which it belongs has <code>output: true</code> in the site's configuration.
          </p>
      </td>
    </tr>
    <tr>
      <td>
        <p><code>collection</code></p>
      </td>
      <td>
        <p>
          The name of the document's collection.
        </p>
      </td>
    </tr>
    <tr>
      <td>
        <p><code>date</code></p>
      </td>
      <td>
        <p>
          The date of the document's collection.
        </p>
      </td>
    </tr>
  </tbody>
</table>

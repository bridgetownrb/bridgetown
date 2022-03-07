---
title: Static Files
order: 130
top_section: Writing Content
category: static-files
---

A static file is a file that does not contain any front matter. These
include images, PDFs, and other un-rendered content.

You can save static files in any subfolder or directly within the source folder (`src`). A common place to save images specifically is the `src/images` folder. You can reference them from both markup and CSS simply using a relative URL (for example, `/images/logo.svg`).

{%@ Note do %}
  Optionally, you can [bundle images through esbuild or Webpack](/docs/frontend-assets) and reference them with the `asset_path` helper. Or if you're interested in a full-featured image management solution with the ability to resize and optimize your media sizes, check out [Cloudinary](https://www.cloudinary.com) and the [bridgetown-cloudinary plugin](https://github.com/bridgetownrb/bridgetown-cloudinary).
{% end %}

Static files can be searched and accessed in templates via `site.static_files` and contain the
following metadata:

<table class="settings biggest-output">
  <thead>
    <tr>
      <th>Variable</th>
      <th>Description</th>
    </tr>
  </thead>
  <tbody>
    <tr>
      <td><p><code>file.path</code></p></td>
      <td><p>

        The relative path to the file, e.g. <code>/assets/img/image.jpg</code>

      </p></td>
    </tr>
    <tr>
      <td><p><code>file.modified_time</code></p></td>
      <td><p>

        The time the file was last modified, e.g. <code>2016-04-01 16:35:26 +0200</code>

      </p></td>
    </tr>
    <tr>
      <td><p><code>file.name</code></p></td>
      <td><p>

        The string name of the file e.g. <code>image.jpg</code> for <code>image.jpg</code>

      </p></td>
    </tr>
    <tr>
      <td><p><code>file.basename</code></p></td>
      <td><p>

        The string basename of the file e.g. <code>image</code> for <code>image.jpg</code>

      </p></td>
    </tr>
    <tr>
      <td><p><code>file.extname</code></p></td>
      <td><p>

        The extension name for the file, e.g.
        <code>.jpg</code> for <code>image.jpg</code>

      </p></td>
    </tr>
  </tbody>
</table>

Note that in the above table, `file` representes a variable used in logic such as a for loop—you can name it whatever you wish in your own code.

## Add front matter to static files

Although you can't directly add front matter values to static files, you can set front matter values through the [defaults property](/docs/content/front-matter-defaults/) in your configuration file. When Bridgetown builds the site, it will use the front matter values you set.

Here's an example:

In your `bridgetown.config.yml` file, add the following values to the `defaults` property:

```yaml
defaults:
  - scope:
      path: "images"
    values:
      image: true
```

When Bridgetown builds the site, it will treat each image as if it had the front matter value of `image: true`.

Now suppose you want to list all your image assets as contained in `src/images`. You could use this Liquid `for` loop to look in the `static_files` object and get all static files that have this front matter property:

{% raw %}
```liquid
{% assign image_files = site.static_files | where: "image", true %}
{% for myimage in image_files %}
  {{ myimage.path }}
{% endfor %}
```
{% endraw %}

When you build your site, the output will list the path to each file that meets this front matter condition.

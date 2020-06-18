---
title: Folder Structure
order: 7
next_page_order: 7.5
top_section: Structure
category: structure
---

The typical folder structure for a Bridgetown site usually looks something like this:

```shell
.
├── frontend # this is where you put your frontend assets for Webpack
│   ├── javascript
│   │   ├── index.js
│   │   └── widget.js
│   ├── styles
│   │   ├── index.scss
│   └   └── layout.scss
├── src # this is where you put your content and design templates
│   ├── _components
│   │   ├── footer.liquid
│   │   └── header.liquid
│   ├── _data
│   │   ├── members.yml
│   │   └── site_metadata.yml
│   ├── _layouts
│   │   ├── default.html
│   │   └── post.html
│   ├── _posts
│   │   ├── 2019-10-29-why-im-dressing-up-as-thanos-this-year.md
│   │   └── 2020-04-12-isolation-is-really-getting-to-me.md
│   ├── 404.html
│   ├── some_page.md
│   └── index.html # or index.md
├── output # this is the generated site published via bridgetown build/serve
├── plugins # this is where you can write custom plugins
├── bridgetown.config.yml # this is your Bridgetown configuration file
├── Gemfile
├── package.json
└── webpack.config.js
```
{:.minimal-line-height}

{:.note}
The location of pages in your source folder structure will by default be mirrored in your output folder, whereas posts are handled in a special way. You can customize these <a href="/docs/structure/permalinks/">permalinks</a> via front matter and global configuration options.

## Overview of Files & Folders

<table class="settings bigger-output">
  <thead>
    <tr>
      <th style="width:25%">File / Directory</th>
      <th>Description</th>
    </tr>
  </thead>
  <tbody>
    <tr>
      <td>
        <p class="default mt-0"><code>src/_components</code></p>
      </td>
      <td>
        <p>
          Liquid components (aka partials) which can be referenced by your layouts, posts, and pages to comprise a design system and facilitate template reuse. The tag <code>{% raw %}{% render "card" %}{% endraw %}</code> would insert the <code>_components/card.liquid</code> component.
        </p>
      </td>
    </tr>
    <tr>
      <td>
        <p class="default mt-0"><code>src/_data</code></p>
      </td>
      <td>
        <p>
          A place for well-formatted structured data. Bridgetown will autoload these files and they will then be accessible via <code>site.data</code>. For example, given <code>members.yml</code>, you can access the contents of that file via <code>site.data.members</code>. Supported formats are: <code>.yml/.yaml</code>, <code>.json</code>, <code>.csv</code>, and <code>.tsv</code>.
        </p>
      </td>
    </tr>
    <tr>
      <td>
        <p class="default mt-0"><code>src/_layouts</code></p>
      </td>
      <td>
        <p>
          These are the templates that wrap posts, pages, and even other layouts. Layouts are chosen on a file-by-file basis via the <a href="/docs/front-matter/">front matter</a> (and you can configure default layouts for different document types or folder paths). The Liquid tag <code>{% raw %}{{ content }}{% endraw %}</code> is used to inject page content into the layout template.
        </p>
      </td>
    </tr>
    <tr>
      <td>
        <p class="default mt-0"><code>src/_posts</code></p>
      </td>
      <td>
        <p>
          This is where you add dynamic blog-style content. The naming convention of these files is important, and must follow the <nobr>format: <code>YEAR-MONTH-DAY-post-title.EXT</code></nobr> (aka <code>.md</code>, <code>.html</code>, etc.). The <a href="/docs/structure/permalinks/">permalink</a> can be customized for each post. Posts are a built-in <a href="/docs/collections">collection</a>, and you can configure other collections in addition to (or even instead of) posts.
        </p>
      </td>
    </tr>
    <tr>
      <td>
        <p class="default mt-0"><code>src/index.html</code> or <code>src/index.md</code> and other HTML,
        Markdown, etc. pages</p>
      </td>
      <td>
        <p>
          Provided that the file has a <a href="/docs/front-matter/">front matter</a> section, it will be transformed by Bridgetown. You can create subfolders (and subfolders of subfolders) to organize your pages.
        </p>
      </td>
    </tr>
    <tr>
      <td>
        <p>General files/folders in the source folder</p>
      </td>
      <td>
        <p>
          Every other directory and file except for those listed above—such as images folders, downloadable files, <code>favicon.ico</code> files, and so forth—will be copied verbatim to the generated site.
        </p>
      </td>
    </tr>
    <tr>
      <td>
        <p class="default mt-0"><code>plugins</code></p>
      </td>
      <td>
        <p>
          This is where you'll write custom plugins for your site to use.
          (Third-party plugins are installed as Gems via Bundler.) Typically
          there will be one <code>site_builder.rb</code> superclass, and you
          will add new builder subclasses to the <code>plugins/builders</code>
          folder. Read all about it in the <a href="/docs/plugins/">Plugins
          documentation</a>.
        </p>
      </td>
    </tr>
    <tr>
      <td>
        <p class="default mt-0"><code>output</code></p>
      </td>
      <td>
        <p>
          This is where the generated site will be placed once Bridgetown is done transforming it. It’s a good idea to add this to your <code>.gitignore</code> file.
        </p>
      </td>
    </tr>
    <tr>
      <td>
        <p class="default mt-0"><code>.bridgetown-metadata</code><br/><code>.bridgetown-cache</code></p>
      </td>
      <td>
        <p>
          <code>.bridgetown-metadata</code> helps Bridgetown keep track of which files have not been modified since the site was last built and which files will need to be regenerated on the next build. <code>.bridgetown-cache</code> is used to improve performance over multiple builds. It’s a good idea to add these to your <code>.gitignore</code> file.
        </p>
      </td>
    </tr>
    <tr>
      <td>
        <p class="default mt-0"><code>bridgetown.config.yml</code></p>
      </td>
      <td>
        <p>
          Stores <a href="/docs/configuration/">configuration</a> data. A few of these options can be specified from the command line executable but it’s generally preferable to save them here.
        </p>
      </td>
    </tr>
    <tr>
      <td>
        <p class="default mt-0"><code>Gemfile</code></p>
      </td>
      <td>
        <p>
          Used by Bundler to install the relevant Ruby gems for your Bridgetown site.
        </p>
      </td>
    </tr>
    <tr>
      <td>
        <p class="default mt-0"><code>package.json</code><br/><code>start.js</code><br/><code>sync.js</code></p>
      </td>
      <td>
        <p>
          Manifest used by Yarn to install frontend assets and set up commands you can run to compile your Javascript, CSS, etc. via Webpack—as well as perform other tasks. Typically there are a couple scripts that are used to load the live-reload Browsersync server and run the Bridgetown and Webpack watchers simultaneously.
        </p>
      </td>
    </tr>
    <tr>
      <td>
        <p class="default mt-0"><code>webpack.config.js</code></p>
      </td>
      <td>
        <p>
          Configuration file used by Webpack to compile frontend assets and save them to the output folder alongside your Bridgetown content.
        </p>
      </td>
    </tr>
  </tbody>
</table>

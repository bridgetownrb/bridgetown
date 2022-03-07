---
title: Folder Structure
order: 70
top_section: Writing Content
category: structure
---

The typical folder structure for a Bridgetown site usually looks something like this:

```shell
.
├── config # this is where frontend and server defaults are stored
├── frontend # this is where you put your CSS and JS for esbuild/Webpack
│   ├── javascript
│   │   ├── index.js
│   │   └── widget.js
│   ├── styles
│   │   ├── index.css
│   └   └── layout.css
├── server # this is where you can (optionally) add API routes using Roda
├── src # this is where you put your resources and design templates
│   ├── _components
│   │   ├── footer.liquid
│   │   └── header.liquid
│   ├── _data
│   │   ├── members.yml
│   │   └── site_metadata.yml
│   ├── _layouts
│   │   ├── default.erb
│   │   └── post.serb
│   ├── _posts
│   │   ├── 2021-09-18-enjoying-the-celebration.md
│   │   └── 2022-04-07-checking-out-bridgetown-now.md
│   ├── images
│   │   └── logo.svg
│   ├── 404.html
│   ├── some_page.md
│   └── index.html # or index.md
├── output # this is the generated site after build process
├── plugins # this is where you can write custom plugins
├── bridgetown.config.yml # this is your Bridgetown configuration file
├── config.ru # Puma uses this to boot up the web server
├── esbuild.config.js # frontend bundler config
├── Gemfile
├── Rakefile
└── package.json
```
{:.minimal-line-height}

{:.note}
The location of pages in your source folder structure will by default be mirrored in your output folder, whereas posts are handled in a special way. You can customize these <a href="/docs/content/permalinks">permalinks</a> via front matter and global configuration options.

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
          A location for all your <a href="/docs/components">components</a> which can be referenced by your layouts and resources to comprise a design system and facilitate template reuse. In Liquid, <code>{% raw %}{% render "card" %}{% endraw %}</code> would insert the <code>_components/card.liquid</code> component. You can create Ruby components as well and save them here for use in Ruby layouts and resource files.
        </p>
      </td>
    </tr>
    <tr>
      <td>
        <p class="default mt-0"><code>src/_data</code></p>
      </td>
      <td>
        <p>
          A place for well-formatted <a href="/docs/datafiles">structured data</a>. Bridgetown will autoload these files and they will then be accessible via <code>site.data</code>. For example, given <code>members.yml</code>, you can access the contents of that file via <code>site.data.members</code>. Supported formats are: <code>.yml/.yaml</code>, <code>.json</code>, <code>.csv</code>, <code>.tsv</code>, and <code>.rb</code>.
        </p>
      </td>
    </tr>
    <tr>
      <td>
        <p class="default mt-0"><code>src/_layouts</code></p>
      </td>
      <td>
        <p>
          These are the <a href="/docs/layouts">templates</a> that wrap resources and even other layouts. Layouts are chosen on a file-by-file basis via the <a href="/docs/front-matter/">front matter</a> (and you can configure default layouts for different collections or folder paths).
        </p>
      </td>
    </tr>
    <tr>
      <td>
        <p class="default mt-0"><code>src/_posts</code></p>
      </td>
      <td>
        <p>
          This is where you add dynamic blog-style content. The naming convention of these files is important, and must follow the format: <code>YEAR-MONTH-DAY-post-title.EXT</code> (aka <code>.md</code>, <code>.html</code>, etc.). The <a href="/docs/content/permalinks">permalink</a> can be customized for each post. Posts are a built-in <a href="/docs/collections">collection</a>, and you can configure other collections in addition to (or even instead of) posts.
        </p>
      </td>
    </tr>
    <tr>
      <td>
        <p class="default mt-0"><code>src/images</code></p>
      </td>
      <td>
        <p>
          You can save images here and reference them in both your markup and CSS (e.g. <code>/images/logo.svg</code>). The name of the <code>images</code> folder is completely arbitrary…feel free to rename it or relocate it under a parent <code>assets</code> folder.
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
          Provided that the file has a <a href="/docs/front-matter">front matter</a> section, it will be transformed by Bridgetown as a <a href="/docs/resources">resource</a>. You can create subfolders (and subfolders of subfolders) to organize your pages. You can also locate pages within <code>_pages</code> to line up with <code>_posts</code>, <code>_data</code>, etc.
        </p>
      </td>
    </tr>
    <tr>
      <td>
        <p>General files/folders in the source folder</p>
      </td>
      <td>
        <p>
          Every other directory and file except for those listed above—such as downloadable files, <code>favicon.ico</code>, <code>robots.txt</code>, and so forth—will be copied verbatim to the generated site as <a href="/docs/static-files">Static Files</a>.
        </p>
      </td>
    </tr>
    <tr>
      <td>
        <p class="default mt-0"><code>output</code></p>
      </td>
      <td>
        <p>
          This is where the generated site will be placed once Bridgetown is done transforming all the content.
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
        <p class="default mt-0"><code>server</code></p>
      </td>
      <td>
        <p>
          This contains the base Roda appplication structure, used by Bridgetown to faciliate both the static files server and <a href="/docs/routes">SSR/dynamic routes (if present)</a>.
        </p>
      </td>
    </tr>
    <tr>
      <td>
        <p class="default mt-0"><code>.bridgetown-cache</code></p>
      </td>
      <td>
        <p>
          <code>.bridgetown-cache</code> is used to improve performance over multiple builds by storing the results of expensive operations.
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
        <p class="default mt-0"><code>package.json</code></p>
      </td>
      <td>
        <p>
          Manifest used by Yarn to install frontend assets and set up commands you can run to compile your JavaScript, CSS, etc. via esbuild/Webpack.
        </p>
      </td>
    </tr>
    <tr>
      <td>
        <p class="default mt-0"><code>esbuild.config.js</code></p>
      </td>
      <td>
        <p>
          Configuration file used by esbuild to compile frontend assets and save them to the output folder alongside your Bridgetown content.
        </p>
      </td>
    </tr>
  </tbody>
</table>

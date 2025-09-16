---
title: Data Files
order: 120
top_section: Writing Content
category: data-files
---

In addition to standard [resources](/docs/resources), you can specify custom datasets which are accessible via Liquid and Ruby templates as well as plugins.

Bridgetown supports loading data from [YAML](http://yaml.org/), [JSON](http://www.json.org/), [CSV](https://en.wikipedia.org/wiki/Comma-separated_values), and [TSV](https://en.wikipedia.org/wiki/Tab-separated_values) files located in the `src/_data` folder. Note that CSV and TSV files *must* contain a header row.

You can also save standard Ruby files (`.rb`) to `_data` which get automatically evaluated. The return value at the end of the file can either be an array or any object which responds to `to_h` (and thus returns a `Hash`).

This feature allows you to avoid repetition in your templates and set site-specific options. In the case of Ruby data files, you can perform powerful processing tasks to populate your site content.

{{ toc }}

## The Data Folder

The `_data` folder is where you can save YAML, JSON, or CSV files (using either the `.yml`, `.yaml`, `.json` or `.csv` extension), and they will be accessible via `site.data` or `site.signals` (more on that below). Also, any files ending in `.rb` within the data folder will be evaluated as Ruby code with a Hash formatted output.

## The Metadata File

You can store site-wide metadata variables in `_data/site_metadata.yml` so they'll be easy to access and will regenerate pages when changed. This is a good place to put `<head>` content like your website title, description, favicon, social media handles, etc. Then you can reference `site.metadata.title`, etc. in your Liquid and Ruby templates.

Want to switch to using a `site_metadata.rb` file where you have more programmatic control over the data values, can easily load in `ENV` variable, etc.? Now you can! For example:

```ruby
# src/_data/site_metadata.rb
{
  title: "Your Ruby Website",
  lang: ENV["LANG"],
  tagline: "All we need is Ruby"
}
```

## Example: Define a List of members

Here is a basic example of using data files to avoid copy-pasting large chunks of code in your Bridgetown templates:

In `_data/members.yml`:

```yaml
- name: Eric Mill
  github: konklone

- name: Parker Moore
  github: parkr

- name: Liu Fengyun
  github: liufengyun
```

Or `_data/members.csv`:

```
name,github
Eric Mill,konklone
Parker Moore,parkr
Liu Fengyun,liufengyun
```

This data can be accessed via `site.data.members` (notice that the filename determines the variable name).

You can now render the list of members in a template:

{%@ Documentation::Multilang do %}
```erb
<ul>
<% site.data.members.each do |member| %>
  <li>
    <a href="https://github.com/<%= member.github %>" rel="noopener">
      <%= member.name %>
    </a>
  </li>
<% end %>
</ul>
```
===
{% raw %}
```liquid
<ul>
{% for member in site.data.members %}
  <li>
    <a href="https://github.com/{{ member.github }}" rel="noopener">
      {{ member.name }}
    </a>
  </li>
{% endfor %}
</ul>
```
{% endraw %}
{% end %}

## Subfolders

Data files can also be placed in subfolders of the `_data` folder. Each folder level will be added to a variable's namespace. The example below shows how GitHub organizations could be defined separately in a file under the `orgs` folder:

In `_data/orgs/bridgetownrb.yml`:

```yaml
username: bridgetownrb
name: Bridgetown
members:
  - name: Jared White
    github: jaredcwhite

  - name: Gilbert the Cat
    github: gilbertkitty
```

In `_data/orgs/doeorg.yml`:

```yaml
username: doeorg
name: Doe Org
members:
  - name: John Doe
    github: jdoe
```

The organizations can then be accessed via `site.data.orgs`, followed by the file name:

{%@ Documentation::Multilang do %}
```erb
<ul>
<% site.data.orgs.each do |_key, org| %>
  <li>
    <a href="https://github.com/<%= org.username %>" rel="noopener">
      <%= org.name %>
    </a>
    (<%= org.members.count %> members)
  </li>
<% end %>
</ul>
```
===
{% raw %}
```liquid
<ul>
{% for org_hash in site.data.orgs %}
  {% assign org = org_hash[1] %}
  <li>
    <a href="https://github.com/{{ org.username }}" rel="noopener">
      {{ org.name }}
    </a>
    ({{ org.members | size }} members)
  </li>
{% endfor %}
</ul>
```
{% endraw %}
{% end %}

## Merging Site Data into Resource Data

For easier access to data in your templates whether that data comes from the resource directly or from data files, you can use [front matter](/docs/front-matter/) to specify a data path for merging into the resource.

Define a front matter variable in a resource like so:

```yaml
---
title: Projects
projects: site.data.projects
---
```

Now in your template you can reference `data.projects` exactly like `data.title` or any other front matter variable. You can even use [front matter defaults](/docs/content/front-matter-defaults/) to assign such a data variable to multiple resources at once.

### Example: Accessing a Specific Author

You can access a specific data item from a dataset using a front matter variable. The example below shows how. First, define your dataset:

`_data/people.yml`:

```yaml
dave:
  name: David Smith
  mastodon: coolpeople.social/@dsmith
```

That author can then be specified as a variable in a post's front matter:

{%@ Documentation::Multilang do %}
```erb
---
title: Sample Post
author: dave
people: site.data.people
---

<% author = data.people[data.author] %>

<a rel="author" href="https://<%= author.mastodon %>">
  <%= author.name %>
</a>
```
===
{% raw %}
```liquid
---
title: Sample Post
author: dave
people: site.data.people
---

{% assign author = data.people[data.author] %}

<a rel="author" href="https://{{ author.mastodon }}">
  {{ author.name }}
</a>
```
{% endraw %}
{% end %}

## Using Signals for Fast Refresh Tracking

**New in Bridgetown 2.0:**  One of the downsides to using the `site.data` hash is it won't be tracked by the **fast refresh** process. This means if you update something in a data file after the development server has booted up, you won't immediately see any changes appear. You would have to also go resave the template (resource/layout/etc.) which _references_ that data file in order to see that something has been updated.

Instead, you could utilize `site.signals`. This is a newer construct which works in exactly the same way as `site.data` but it creates a "tracking subscription" automatically. Now when you access `site.signals.stuff.here`, anything in the `src/_data/stuff.yml` file for example which you go and change, you'll then see fast refresh work on the pages which reference it.

{%@ Note type: :warning do %}
This feature only works in Ruby-based templates. We don't offer a `site.signals` variable within in Liquid templates.
{% end %}

{%@ Note do %}
In a future version of Bridgetown, we are planning to make `site.data` itself use signals, and alias `site.signals` to that, but due to compatibility concerns with existing projects we decided to make it an opt-in feature for now.
{% end %}

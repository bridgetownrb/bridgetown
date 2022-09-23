---
title: Data Files
order: 120
top_section: Writing Content
category: data-files
---

In addition to standard [resources](/docs/resources), you can specify custom datasets which are accessible via Liquid and Ruby templates as well as plugins.

Bridgetown supports loading data from [YAML](http://yaml.org/), [JSON](http://www.json.org/), [CSV](https://en.wikipedia.org/wiki/Comma-separated_values), and [TSV](https://en.wikipedia.org/wiki/Tab-separated_values) files located in the `src/_data` folder. Note that CSV and TSV files *must* contain a header row.

You can also save standard Ruby files (`.rb`) to `_data` which get automatically evaluated. The return value at the end of the file can either be an array or any object which responds to `to_h` (and thus returns a `Hash`).

This powerful feature allows you to avoid repetition in your templates and set site-specific options without changing `bridgetown.config.yml`—and in the case of Ruby data files, perform powerful processing tasks to populate your site content.

{{ toc }}

## The Data Folder

The `_data` folder is where you can save YAML, JSON, or CSV files (using either the `.yml`, `.yaml`, `.json` or `.csv` extension), and they will be accessible via `site.data`. Also, any files ending in `.rb` within the data folder will be evaluated as Ruby code with a Hash formatted output.

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

## Merging Site Data into Resource Data

New for Bridgetown 1.2: for easier access to data in your templates whether that data comes from the resource directly or from data files, you can use [front matter](/docs/front-matter/) to specify a data path for merging into the resource.

Just define a front matter variable in a resource like so:

```yaml
---
title: Projects
projects: site.data.projects
---
```

Now in your template you can reference `data.projects` just like you might `data.title` or any other front matter variable. You can even use [front matter defaults](/docs/content/front-matter-defaults/) to assign such a data variable to multiple resources at once.

### Example: Accessing a Specific Author

You can access a specific data item from a dataset using a front matter variable. The example below shows how. First, define your dataset:

`_data/people.yml`:

```yaml
dave:
  name: David Smith
  twitter: DavidSilvaSmith
```

That author can then be specified as a variable in a post's front matter:

{% raw %}
```liquid
---
title: Sample Post
author: dave
people: site.data.people
---

{% assign author = data.people[data.author] %}

<a rel="author" href="https://twitter.com/{{ author.twitter }}">
  {{ author.name }}
</a>
```
{% endraw %}

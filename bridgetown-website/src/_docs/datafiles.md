---
title: Data Files
order: 14
top_section: Content
category: datafiles
---

In addition to the [built-in variables]({{'/docs/variables/' | relative_url }}) available from Bridgetown,
you can specify your own custom data that can be accessed via Liquid.

Bridgetown supports loading data from [YAML](http://yaml.org/), [JSON](http://www.json.org/), [CSV](https://en.wikipedia.org/wiki/Comma-separated_values), and [TSV](https://en.wikipedia.org/wiki/Tab-separated_values) files located in the `_data` folder.
Note that CSV and TSV files *must* contain a header row.

This powerful feature allows you to avoid repetition in your templates and to
set site specific options without changing `bridgetown.config.yml`.

Plugins can also leverage Data Files to set configuration variables.

## The Data Folder

The `_data` folder is where you can store additional data for Bridgetown to use when
generating your site. These files must be YAML, JSON, or CSV files (using either
the `.yml`, `.yaml`, `.json` or `.csv` extension), and they will be
accessible via `site.data`.

## Example: List of members

Here is a basic example of using Data Files to avoid copy-pasting large chunks
of code in your Bridgetown templates:

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

This data can be accessed via `site.data.members` (notice that the filename
determines the variable name).

You can now render the list of members in a template:

{% raw %}
```liquid
<ul>
{% for member in site.data.members %}
  <li>
    <a href="https://github.com/{{ member.github }}">
      {{ member.name }}
    </a>
  </li>
{% endfor %}
</ul>
```
{% endraw %}

## Subfolders

Data files can also be placed in subfolders of the `_data` folder. Each folder
level will be added to a variable's namespace. The example below shows how
GitHub organizations could be defined separately in a file under the `orgs`
folder:

In `_data/orgs/jekyll.yml`:

```yaml
username: jekyll
name: Bridgetown
members:
  - name: Tom Preston-Werner
    github: mojombo

  - name: Parker Moore
    github: parkr
```

In `_data/orgs/doeorg.yml`:

```yaml
username: doeorg
name: Doe Org
members:
  - name: John Doe
    github: jdoe
```

The organizations can then be accessed via `site.data.orgs`, followed by the
file name:

{% raw %}
```liquid
<ul>
{% for org_hash in site.data.orgs %}
{% assign org = org_hash[1] %}
  <li>
    <a href="https://github.com/{{ org.username }}">
      {{ org.name }}
    </a>
    ({{ org.members | size }} members)
  </li>
{% endfor %}
</ul>
```
{% endraw %}

## Example: Accessing a specific author

Pages and posts can also access a specific data item. The example below shows how to access a specific item:

`_data/people.yml`:

```yaml
dave:
    name: David Smith
    twitter: DavidSilvaSmith
```

The author can then be specified as a page variable in a post's front matter:

{% raw %}
```liquid
---
title: sample post
author: dave
---

{% assign author = site.data.people[page.author] %}
<a rel="author"
  href="https://twitter.com/{{ author.twitter }}"
  title="{{ author.name }}">
    {{ author.name }}
</a>
```
{% endraw %}

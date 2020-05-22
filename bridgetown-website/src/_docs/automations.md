---
order: 6.5
next_page_order: 7
title: Automations
top_section: Configuration
category: automations
---

**_New_** in Bridgetown 0.15, you can write automation scripts which act on new
or existing sites to perform tasks such as adding gems, updating configuration,
inserting code, copying files, and much more.

Automations are similar in concept to Gatsby Recipies or Rails App Templates.
They're uniquely powerful when combined with [plugins](/docs/plugins), as an
automation can install and configure one or more plugins from a single script.

You could also write an automation to run multiple additional automations, and
apply that to a brand-new site to set everything up just how you want it in a
repeatable and automatic fashion.

Automations can be loaded from a local path, or they can be loaded from remote
URLs including GitHub repositories and gists.

{% rendercontent "docs/note" %}
For a directory of useful automations built by the Bridgetown community, check
out the [Bridgetown Automations](https://github.com/bridgetownrb/automations)
repo.
{% endrendercontent %}

## Running Automations

For a new site, you can apply an automation as part of the creation process
using `--apply=` or -`a`:

```sh
bundle exec bridgetown new mysite --apply=/path/to/automation.rb
```

For existing sites, you can use the `apply` command:

```sh
bundle exec bridgetown apply /path/to/automation.rb
```

If you don't supply any filename or URL to `apply`, it will look for
`bridgetown.automation.rb` in the current working directory

```sh
vim bridgetown.automation.rb # save an automation script

bundle exec bridgetown apply
```

Remote URLs to automation scripts are also supported, and GitHub repo or gist
URLs are automatically transformed to locate the right file from GitHub's CDN:

```sh
# Install and configure the bridgetown-cloudinary gem
bundle exec bridgetown apply https://github.com/bridgetownrb/bridgetown-cloudinary
```

You can also load a file other than `bridgetown.automation.rb` from GitHub:

```sh
# Install and configure the bridgetown-cloudinary gem
bundle exec bridgetown apply https://github.com/bridgetownrb/automations/netlify.rb
```

## Writing Automations

TBC…

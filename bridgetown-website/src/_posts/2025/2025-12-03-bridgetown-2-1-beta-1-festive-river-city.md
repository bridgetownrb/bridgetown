---
date: Wed, 03 Dec 2025 11:18:55 -0800
title: "Let’s Get Festive! ’Tis the Season to Be Jolly with Bridgetown 2.1 Beta 1"
subtitle: "Several exciting new features and yet more under-the-hood refactoring & infrastructure work sets us up well for future feature development in 2026."
author: jared
category: release
---

A mere three months after [the release of Bridgetown 2.0](/release/bridgetown-v2-river-city-released/) and we're already onto 2.1?! What can I say…when you're on a roll, you're on a roll. And things are definitely rolling here in Bridgetown as we celebrate our **"Festive River City 🥳"** (we just couldn't part ways with the River City branding just yet, hence our "Snow Leopard" style code name!).

With the end-of-year holidays upon us, we're excited to be presenting several exciting new features and yet more under-the-hood refactoring & infrastructure work which sets us up well for future feature development in 2026. While there are possibly some breaking changes in 2.1 (which is why we opted for a beta cycle), we hope to mitigate those as much as possible or offer clear instructions on how to correct swiftly. Your feedback during the beta is most appreciated!

[Read the release notes here.](https://github.com/bridgetownrb/bridgetown/releases/tag/v2.1.0.beta1) To test your sites with the 2.1 beta, modify your `Gemfile`:

```ruby
gem "bridgetown", "~> 2.1.0.beta1"
gem "bridgetown-routes", "~> 2.1.0.beta1" # if applicable
```

and run `bundle update`. Or you can run `gem install bridgetown -N -v 2.1.0.beta1` to create a new site.

### External Content Sources (Markdown Apps, Digital Gardens, Wikis, etc.)

Have you ever thought to yourself: "Self, wouldn't it be awesome if I could just point Bridgetown at a folder full of Markdown files and it would just render??"

**Your wish is our command.** ✨

In Bridgetown 2.1, you can now add one or more "external content" sources via an initializer which can be literally any folder on the filesystem, even the parent folder! Yes, Bridgetown now supports "folder inversion" as an alternative installation approach, which means in addition to placing Markdown files and related assets in `src`, you can write Markdown in the folder _above_ where Bridgetown is installed (and in various subfolders thereof). Not only that, but **front matter is completely optional!** This is perfect for "digital gardens", wikis, and other file-based content systems managed by third-party Markdown apps such as Obsidian. (And you'd better believe we have a whole bunch of wiki-themed improvements in mind for future releases.) 😎 [Read our docs for more information.](/docs/content/external-sources)

### Universal Rendering for Partials & Components

A limitation of how our rendering system worked for partials in the past was that you could only use partials within the same template engine. So if you were writing an ERB template, you couldn't use a Serbea partial. Or if you were in a Serbea template, you couldn't use a pure Ruby (`.rb`) partial.

That has now been fixed! Any template engine can render any partial whether ERB, Serbea, or pure Ruby. On top of that, you can now render both partials & components to strings from any context (not just within a template)—including the console! [Read our docs for more information.](/docs/template-engines/erb-and-beyond#universal-rendering)

Speaking of the console, you now have access to the [Rack::Test](https://github.com/rack/rack-test) DSL (if the gem is installed, which happenes automatically if you use the `minitesting` bundled configuration). This is great for testing both static & dynamic routes directly within the REPL.

### Samovar, Freyia, and Custom Commands

In Bridgetown 2.1, we've migrated away from using Thor for our command-line interface (CLI) and are now using [Samovar](https://github.com/ioquatix/samovar), created by Samuel Williams. It provides a straightforward, modern, and elegant way to write commands, and as a bonus, we've made it much easier for you to extend Bridgetown's CLI with your own commands in any project! Just create a `config/custom_commands.rb` file and add your own `Bridgetown::Command` subclasses. We believe in most cases this is a more powerful & flexible solution than authoring new Rake tasks. [Read our docs for more information.](/docs/plugins/commands)

Note that for the 2.1 release cycle, we have provided a Thor "shim" so existing sites and plugins which provide Thor commands should continue to work as before. In a future release, we will be removing the shim so please update your commands accordingly. In the meantime, if you run into any compatibility issues with the shim please report them and let us know!

Another of our prior uses of Thor was for the Automations functionality (which also powers our Bundled Configurations). Because this functionality is so important, and also near-impossible to replicate verbatim using an alternative library, we have _extracted_ the "actions" & "shell" portions of Thor as a hard fork out to a new gem called [Freyia](https://codeberg.org/jaredwhite/freyia). We will be actively developing Freyia as its own independent project going forward, refactoring and adding new features as needed.

### Removal of Active Support

As part of our pledge to ensure Bridgetown is free of dependencies directly managed by 37signals, we have finialized the removal of the Active Support gem. If you have written your own code which assumes the availability of Active Support, you may need to `bundle add activesupport` and require pieces of it yourself. For example, if you want to use `.blank?`, `.present?`, etc., add the gem and include the following in your `config/initializers.rb` file:

```ruby
require "active_support/core_ext/object/blank"
```

[Documentation on Active Support is available here.](https://guides.rubyonrails.org/v8.0/active_support_core_extensions.html)

### Supporting Alternatives to Big Tech

We continue to push for awareness of "indie web" and sustainable alternatives to Big Tech solutions. Our documentation now includes [information on how to deploy](/docs/deployment#statichosteu) static Bridgetown sites to [statichost.eu](https://statichost.eu), and our Automations feature can load automation scripts from Codeberg and GitLab repositories in addition to GitHub.

----

As always if you run into any issues trying out Bridgetown 2.1, [please hop into our community channels](/community) and let us know how we can help. We welcome your feedback and ideas! In addition, you can [follow us on Bluesky](https://bsky.app/profile/bridgetownrb.com) and [the fediverse](https://ruby.social/@bridgetown) to stay current on the latest news.

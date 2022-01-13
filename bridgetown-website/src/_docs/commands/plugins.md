---
title: Plugins Command
order: 0
top_section: Setup
category: command-line-usage
---

The `plugins` command allows you to display all custom or gem-based plugins you have loaded in the site along with other related infrastructure such as source manifests, generators, and builders.

Simply run `bridgetown plugins list` and you'll get a printout in your terminal that looks something like this:


```
Registered Plugins: 5
                    bridgetown-sample-plugin (~> 1.0)
                    bridgetown-seo-tag (~> 3.0)
                    bridgetown-feed (~> 1.0)
                    plugins/builders/tags.rb
                    plugins/builders/newsletter_digest.rb
  Source Manifests: ---
            Origin: SamplePlugin
        Components: /path/to/bridgetown-sample-plugin/components
           Content: /path/to/bridgetown-sample-plugin/content
           Layouts: /path/to/bridgetown-sample-plugin/layouts
                    ---
          Builders: 3
                    SamplePlugin::Builder
                    NewsletterDigest
                    TagsBuilder
        Converters: 3
                    Bridgetown::Converters::Markdown
                    Bridgetown::Converters::SmartyPants
                    Bridgetown::Converters::Identity
        Generators: 4
                    NewsletterDigest
                    Bridgetown::PrototypeGenerator
                    Bridgetown::Paginate::PaginationGenerator
                    BridgetownFeed::Generator
```

You can read more about builders, generators, etc. in the [Plugins documentation](/docs/plugins).

### Copying Files out of Plugin Source Folders

Bridgetown gem-based plugins/themes which provide [source manifests](/docs/plugins/source-manifests) may add content to your site such as layouts, resources, static files, and components from folders in the gem.

If you ever need to _override_ some of that content, you can use the `plugins cd` command. The syntax is as follows:

```
bridgetown plugins cd <origin>/<dir>
```

where `<origin>` is one of the source manifest origins (like the `SamplePlugin` example above), and `<dir>` is one of the folder names (like `Content` or `Layouts`).

The command drops you in a new temporary shell where you can access the files, and when you're done simply type `exit` to return to your site. In addition, you're given the `BRIDGETOWN_SITE` environment variable as a way to reference your site from the temporary shell.

So for example if you wanted to copy all the layouts from a gem-based plugin into your own site layouts folder, it's as simple as running:

```sh
bridgetown plugins cd AwesomePlugin/Layouts

cp -r * $BRIDGETOWN_SITE/src/_layouts
exit
```
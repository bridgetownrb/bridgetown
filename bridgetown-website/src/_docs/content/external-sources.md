---
title: External Content Sources
order: 0
top_section: Writing Content
category: resources
---

There are times you may want Bridgetown to include resources you've created which live outside of your site project folder hierarchy. In particular, you may have a folder(s) of Markdown files already saved somewhere and would like those to be included in your site build. 

To add a new content source to your project, use the `external_sources` plugin initializer in your `config/initializers.rb` file:

```ruby
init :external_sources do
  contents do
    pages "path/to/folder"
  end
end
```

In this example, `pages` is the name of the collection you want to load the content into. The default `pages` option is a safe bet, but you can set up one or more [custom collections](/docs/collections) and load the content in that way. For example:

```ruby
collections do
  docs do
    output true
    # Using a `:path.*`-style permalink is recommended to ensure links between
    # Markdown files work as intended:
    permalink "documentation/:path.*"
  end
end

# Set up front matter defaults for the collection:
config.defaults << {
  scope: { collection: :docs },
  values: { layout: :default },
}

# Configure the plugin:
init :external_sources do
  contents do
    docs "/var/wiki"
  end
end
```

## Loading Markdown Content from Other Applications

Unlike with standard Bridgetown content files within `src` where you must use front matter if you wish Markdown files get processed as resources instead of static files, Markdown files in external sources don't require any front matter. However, in order to ensure those files are rendered with a layout, you'll need to set up [front matter defaults](/docs/content/front-matter-defaults) (as shown in the example above).

You may also want to set up a hook to establish extra front matter data based on content within the files, such as extracting a `# Title Heading`:

```ruby
# plugins/builders/hooks.rb
class Builders::Hooks < SiteBuilder
  def build
    # Use the name of your collection for the first argument:
    hook :docs, :post_read do |resource|
      title = nil
      resource.content = resource.content.sub(%r!^# .*?$!) do |line|
        title = line.delete_prefix("# ")
        ""
      end
      resource.data.title = title if title
    end
  end
end
```

There are many applications which let you author and edit Markdown content on the filesystem. One such application which has become popular across a variety of platforms is [Obsidian](https://obsidian.md/). An issue you may run into with content systems like this is when links to other Markdown files end in an extension such as `.md`. This will result in **404 Not Found** errors, since the built HTML page URLs do not end in `.md`. You can use an [HTML Inspector](/docs/plugins/inspectors) to locate and remove such extensions:

```ruby
# plugins/builders/inspectors.rb
class Builders::Inspectors < SiteBuilder
  def build
    inspect_html do |document|
      document.query_selector_all("a").each do |anchor|
        next unless anchor[:href].end_with?(".md")

        anchor[:href] = anchor[:href].delete_suffix(".md")
      end
    end
  end
end
```

## Folder Inversion and Minimalist Installations

An interesting method of organizing your content and Bridgetown project sites would be to place all of Bridgetown's Ruby, JavaScript, layouts, templates, and other supporting files in a _subfolder_ of the main content folder. That way, content authors are able to focus on only the content saved at the top-level, with all of the Bridgetown support files tucked away and effectively "hidden". (Perhaps even in a folder named `.bridgetown`!)

```ruby
init :external_sources do
  contents do
    pages ".." # relative paths are always resolved against the Bridgetown root folder
  end
end
```

You also have the option of trimming away some of the boilerplate and support files that Bridgetown ships with by default in a new project. Here is a list of the _only_ files you need for Bridgetown to run:

```shell
├── config
│   └── initializers.rb
├── Gemfile
├── Gemfile.lock
└── src
   └── _layouts
      └── default.erb
```

Note that this doesn't include esbuild for managing frontend assets like JS & CSS (you would need to go "buildless" and do that yourself manually or use CDNs like esm.sh).

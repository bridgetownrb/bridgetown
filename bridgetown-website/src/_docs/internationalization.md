---
title: Internationalization (I18n)
order: 235
top_section: Configuration
category: i18n
---

{%@ Note type: "warning" do %}
During the Bridgetown 1.1 beta cycle, this documentation is still under construction…
{% end %}

Internationalization, or i18n as it's commonly known, is the process of defining content and templates for your site in such a way as to support multiple languages or locales. Whether that's French vs. Chinese, or American English vs. British English, it gives you the ability reach more diverse audiences and constituencies.

Starting in Bridgetown 1.1, you can configure multiple locales for your website and set which particular locale should be considered "the default". There are a couple of different routing options available:

1. The default locale URLs start at the root of the site (`/`), and other locales start at a locale-specific prefix (`/es`, `/de`), etc.
2. All locales start at a locale-specific prefix, and the root (`/`) redirects to the "default" locale at its designated prefix.

Routing options _not_ currently supported by Bridgetown at present are the subdomain config (`www.mysite.com`, `es.mysite.com`, `zh.mysite.com`, etc.) and the international domains config (`www.mysite.com`, `www.mysite.co.uk`, etc.). However, if you're able to work within a prefix-style config ([MDN](https://developer.mozilla.org) is a good example of this type of approach out in the wild), Bridgetown is here for you.

{%@ Note do %}
Bridgetown uses the [Ruby I18n](https://github.com/ruby-i18n/i18n) gem to aid in storing and accessing translations, the same library used by Ruby on Rails. Thus many of the same conventions will apply if you're already familar with i18n in Rails.
{% end %}

{{ toc }}

## Setup & Translations

First, you'll want to define your locales in `bridgetown.config.yml`. There are three configuration options, which by default are:

```yml
available_locales: [en]
default_locale: en
prefix_default_locale: false
```

* `available_locales`: This is an array of locales you wish to support on your site. They can be simple language codes (`es` for Spanish, `th` for Thai, etc.), or they can also include regional differences known as subtags (`pt-BR` for Brazilian Portuguese, `pt-PT` for Portuguese as spoken in Portugal, etc.). [You can look up various languages and subtags here](https://r12a.github.io/app-subtags/). An example value for English, French, and German would be: `[en, fr, de]`.
* `default_locale`: This the locale you wish to consider the "default" for your site (aka the locale a visitor would first encounter before specifically choosing a locale). The default is English: `en`.
* `prefix_default_locale`: As mentioned above, you can either have default locale URLs live within the root of your site, or you can set this to `true` to have the root direct to the default locale's prefix.

Once you've completed your intial configuration, create a `src/_locales` folder and add files in YAML, JSON, or Ruby hash format for your locale translations. The first key of the data structure should be the locale, with various hierarchies of subkeys as you deem fit. Here's an example of a `en.yml` file:

```yaml
en:
  site:
    title: Local Listings
    tagline: The best homes you'll find anywhere in the area.
  welcome:
    intro: Welcome to Local Listings! Enjoy our fine selection.
```

And here's a example of a `es.rb` file:

```rb
{
  es: {
    site: {
      title: "Listados Locales",
      tagline: "Las mejores casas que encontrará en cualquier lugar de la zona."
    },
    welcome: {
      intro: "¡Bienvenido a los listados locales! Disfruta de nuestra fina selección."
    }
  }
}
```

Within your templates, you'll now be able to use the `t` Liquid tag or filter, or the `t` Ruby helper to reference these keys. For example, in Liquid:

{% raw %}
```liquid
{% t site.title %} <!-- tag style -->
{{ "site.tagline" | t }} <!-- filter style -->
```
{% endraw %}

and in ERB:

```erb
<%= t("welcome.intro") %>
```

The Ruby helper in particular also supports variable interpolation. If you store a translation like this:

```yml
en:
  products:
    price: "$%{price}"
```

Then you can pass that variable to the `t` helper:

```erb
<%= t("products.price", price: resource.data.price) %>
```

There are many other useful features of the **i18n** gem, so feel free to peruse the [Rails Guide to Internationalization](https://guides.rubyonrails.org/i18n.html) for additional documentation.

{%@ Note do %}
In Ruby, the `t` helper is simply shorthand for `I18n.t`, so if you find yourself in a context where `t` is not available—perhaps in a plugin—you can write `I18n.t` directly.
{% end %}

## Localizing Your Resources and Templates

Beyond using simple translated strings, you will want to ensure you have translated variants of your content and that you can switch freely between the locale variants. There are two ways to do this:

### Separate Files

Create a separate resource file for each locale. You can either use the `locale` [front matter](/docs/front-matter) key to set the locale of a file, or you can include the locale in the filename itself. For example: `about.en.md`, `about.fr.md`, `about.it.md`, etc. You can do this for any type resource, whether it's a page, blog post, or some other custom collection.

### Multi-Locale Files

Use a single resource file in "multi locale" mode and use special front mater and template syntax to include translated content. You can switch to this mode by setting `locale: multi` in your front matter or using the `.multi` extension within your file name. For example: `about.multi.md`. Then you use the `locale_overrides` front matter key to include keys which will overwrite the default keys for all locales other than the default. Here's an example:

```yaml
---
title: My Title
locale_overrides:
  es:
    title: Mi Título
  de:
    title: Mein Titel
---
```

Then in the body of the resource, you can use conditional template syntax to check the value of the `site.locale` variable. (And of course this works in any layout template as well.) Using ERB syntax:

```erb
<% if site.locale == :en %>

Here's my content in **English**.

<% elsif site.locale == :es %>

Aquí está mi contenido en **Español**.

<% elseif site.locale == :de %>

Hier sind meine Inhalte auf **Deutsch**.

<% end %>
```

### Switching Between Locales

You can use a resource's `all_locales` method to get a list of all matching translated resources. This is perfect for a section of your navbar or site footer which could allow the reader to switch to their preferred locale. Using Liquid:

{% raw %}
```liquid
{% for local_resource in resource.all_locales %}
  <a href="{{ local_resource.relative_url }}">{{ local_resource.data.locale | t }}</a>
{% endfor %}
```
{% endraw %}

### Creating Localized Paths & Filtering Collections

The `in_locale` filter/helper can help you link to another part of the site within the currently rendering locale, such as in navbars, sidebars, footers, etc.

{% raw %}
```liquid
<a href="{{ '/posts' | in_locale | relative_url }}">{% t nav.posts %}</a>
```
{% endraw %}

In addition, if you're accessing and looping through a collection directly, you can use the `in_locale` filter/helper there as well to filter out those resources not in the current locale.

{% raw %}
```liquid
{% assign posts = collections.posts.resources | in_locale %}
{% for post in posts %}
  <li>
    <a href="{{ post.relative_url }}">{{ post.data.title }}</a>
  </li>
{% endfor %}
```
{% endraw %}

### Pagination and Prototype Pages

Whether you use one-file-per-locale or multi-locale files technique, your paginated pages and prototype pages will similarly filter out any resources not in the current locale whenever you access `paginator.resources`.

### Updating `<head>` and other places

Localize any other string with `t` there as well, such as the site title or tagline.

## We Value Your Feedback

I18n is hard to get right, and there can be confusing or unexpected edge cases to work through. We value your questions and your suggestions on how to make Bridgetown a great platform for multi-locale websites and apps.

---
title: Includes
hide_in_toc: true
order: 0
category: structure
---

{% rendercontent "docs/note", title: "Deprecated and Will Be Removed in Bridgetown 1.0", type: "warning" %}
The {% raw %}`{% include %}`{% endraw %} tag is being phased out in favor of the new {% raw %}`{% render %}`{% endraw %} tag
favored by Shopify and used by Bridgetown as the basis of Liquid Components.
You'll want to update your site to use {% raw %}`{% render %}`{% endraw %} and {% raw %}`{% rendercontent %}`{% endraw %} for any inclusion of partials/templates such as headers, footers, nav bars, etc. Read the [Liquid Components](/docs/components) documentation for details.
{% endrendercontent %}

The `include` Liquid tag allows you to include the content from another file stored in the `_includes` folder:

{% raw %}
```liquid
{% include footer.html %}
```
{% endraw %}

Bridgetown will look for the referenced file (in this case, `footer.html`) in the `_includes` folder in your source folder and insert its contents.

### Including files relative to another file

You can choose to include file fragments relative to the current file by using the `include_relative` tag:

{% raw %}
```liquid
{% include_relative somedir/footer.html %}
```
{% endraw %}

You won't need to place your included content within the `_includes` folder. Instead,
the inclusion is specifically relative to the file where the tag is being used. For example,
if `_posts/2014-09-03-my-file.markdown` uses the `include_relative` tag, the included file
must be within the `_posts` directory or one of its subdirectories.

Note that you cannot use the `../` syntax to specify an include location that refers to a higher-level directory.

All the other capabilities of the `include` tag are available to the `include_relative` tag,
such as variables.

### Using variables names for the include file

The name of the file you want to embed can be specified as a variable instead of an actual file name. For example, suppose you defined a variable in your page's front matter like this:

```yaml
---
title: My page
my_variable: footer_company_a.html
---
```

You could then reference that variable in your include:

{% raw %}
```liquid
{% if page.my_variable %}
  {% include {{ page.my_variable }} %}
{% endif %}
```
{% endraw %}

In this example, the include would insert the file `footer_company_a.html` from the `_includes/footer_company_a.html` folder.

### Passing parameters to includes

You can also pass parameters to an include. For example, suppose you have a file called `note.html` in your `_includes` folder that contains this formatting:

<!-- linthtml-configure tag-bans="false" -->
{% raw %}
```liquid
<div markdown="span" class="alert alert-info" role="alert">
<i class="fa fa-info-circle"></i> <b>Note:</b>
{{ include.content }}
</div>
```
{% endraw %}
<!-- linthtml-configure tag-bans="true" -->

The {% raw %}`{{ include.content }}`{% endraw %} is a parameter that gets populated when you call the include and specify a value for that parameter, like this:

{% raw %}
```liquid
{% include note.html content="This is my sample note." %}
```
{% endraw %}

The value of `content` (which is `This is my sample note`) will be inserted into the {% raw %}`{{ include.content }}`{% endraw %} parameter.

Passing parameters to includes is especially helpful when you want to hide away complex formatting from your Markdown content.

For example, suppose you have a special image syntax with complex formatting, and you don't want your authors to remember the complex formatting. As a result, you decide to simplify the formatting by using an include with parameters. Here's an example of the special image syntax you might want to populate with an include:

```html
<figure>
   <a href="http://bridgetownrb.com">
   <img src="logo.png" style="max-width: 200px;"
      alt="Bridgetown logo" />
   </a>
   <figcaption>This is the Bridgetown logo</figcaption>
</figure>
```

You could turn this content into an include partial and make each value available as a parameter, like this:

{% raw %}
```liquid
<figure>
   <a href="{{ include.url }}">
   <img src="{{ include.file }}" style="max-width: {{ include.max-width }};"
      alt="{{ include.alt }}"/>
   </a>
   <figcaption>{{ include.caption }}</figcaption>
</figure>
```
{% endraw %}

This include contains 5 parameters:

* `url`
* `max-width`
* `file`
* `alt`
* `caption`

Here's an example that passes all the parameters to this include (the include file is named `image.html`):

{% raw %}
```liquid
{% include image.html url="http://bridgetownrb.com"
max-width="200px" file="logo.png" alt="Bridgetown logo"
caption="This is the Bridgetown logo." %}
```
{% endraw %}

The result is the original HTML code shown earlier.

To safeguard situations where users don't supply a value for the parameter, you can use [Liquid's default filter](https://shopify.github.io/liquid/filters/default/).

Overall, you can create includes that act as templates for a variety of uses &mdash; inserting audio or video clips, alerts, special formatting, and more. Note that you should avoid using too many includes, as this will slow down the build time of your site. For example, don't use includes every time you insert an image. (The above technique shows a use case for special images.)

### Passing parameter variables to includes

Suppose the parameter you want to pass to the include is a variable rather than a string. For example, you might be using {% raw %}`{{ site.product_name }}`{% endraw %} to refer to every instance of your product rather than the actual hard-coded name. (In this case, your `bridgetown.config.yml` file would have a key called `product_name` with a value of your product's name.)

The string you pass to your include parameter can't contain curly braces. For example, you can't pass a parameter that contains this: {% raw %}`"The latest version of {{ site.product_name }} is now available."`{% endraw %}

If you want to include this variable in your parameter that you pass to an include, you need to store the entire parameter as a variable before passing it to the include. You can use `capture` tags to create the variable:

{% raw %}
```liquid
{% capture download_note %}
The latest version of {{ site.product_name }} is now available.
{% endcapture %}
```
{% endraw %}

Then pass this captured variable into the parameter for the include. Omit the quotation marks around the parameter content because it's no longer a string (it's a variable):

{% raw %}
```liquid
{% include note.html content=download_note %}
```
{% endraw %}

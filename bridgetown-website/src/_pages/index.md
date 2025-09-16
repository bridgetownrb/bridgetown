---
layout: default
exclude_from_search: true
page_class: homepage
---

<main-content>
  <section-wrapper size="large" class="fade-in-animation" invert style="margin-top:-0.5rem">
  <svg-wrapper class="main-wave" style="box-shadow: inset 0px -1px 0px #131e1b">{{ svg "/images/waves/wave_1.svg" }}</svg-wrapper>
  <section style="padding-top:2rem; padding-bottom:2rem" markdown="1">


<p class="heading-icon">
  <img src="/images/ruby-plain.svg" width="45" style="padding-bottom:10px" />
</p>

## Static Sites? Fullstack Applications? Both? Yes, Yes, and Yes.
{:style="color:var(--color-brick);"}

You can truly have it all. Built for an **HTML-first**, "vanilla" web paradigm on the foundational tech of **Ruby**, **Roda**, and **esbuild**, **Bridgetown** puts power back in the hands of individuals to create extraordinary things.

While your competitors are wrestling with complicated build tools, limited programming idioms, and mountains of boilerplate, **you’re out changing the world**.
{:style="margin-left:auto; margin-right:auto; max-width:43em"}

<p>
  <a href="/docs"><sl-button variant="primary" pill size="large">
    <sl-icon slot="prefix" library="remixicon" name="development/code-box"></sl-icon>
    Get Started Today
  </sl-button></a>
</p>
{:style="text-align:center; margin-top:3rem"}

<small class="version-text">Version {{ Bridgetown::VERSION }} released {{ current_version_date }}.
{% if site.data.edge_version %}
Looking for [stable release documentation](https://www.bridgetownrb.com/)?
{% elsif site.data.version_label %}
**This is documentation for {{ site.data.version_label }}.** Looking for [current release documentation](https://www.bridgetownrb.com/)?
{% else %}
**Looking for [edge](https://edge.bridgetownrb.com/docs/), [v1](https://bridgetown-v1.onrender.com/), or [v0](https://bridgetown-v0.onrender.com/) documentation?**
{% end %}</small>

  </section>
  <svg-wrapper class="main-wave">{{ svg "/images/waves/wave_2.svg" }}</svg-wrapper>
</section-wrapper>

<section-wrapper class="fade-in-animation" style="padding-top:2rem">
  <section markdown="1">

<p class="heading-icon">
  <sl-icon library="remixicon" name="business/megaphone-fill"></sl-icon>
</p>

## Listen to what they're saying about Bridgetown:
{:style="font-size:2.3rem"}

{:.info-grid}
- <sl-card markdown="block">

  <q>Bridgetown is doing a wonderful job of bringing the joy of Ruby into the world of modern static site generators.</q>

  [Felipe Vogel](https://fpsvogel.com/posts/2021/build-a-blog-with-ruby-bridgetown)

- <sl-card markdown="block">

  <q>Bridgetown is one of the underdogs in the ecosystem. It has amazing tools and ingredients inside, and is an example of power of Ruby.</q>

  [Alberto Colón Viera](https://youtu.be/5Q0NtSWYI-s?feature=shared)

- <sl-card markdown="block">

  <q>Within a very short period of time I went from a blank VSCode editor to fully designed and deployed website using Bridgetown! 👏</q>

  [@rabbigreenberg](https://xcancel.com/rabbigreenberg/status/1462403305334788099?s=21)

- <sl-card markdown="block">

  <q>Every time I turn around — something new from Bridgetown.</q>

  [@jeffreyguenther](https://xcancel.com/jeffreyguenther/status/1464277154154254339?s=21)

- <sl-card markdown="block">

  <q>I just started my first project using Bridgetown today and I’m already loving it!</q>

  [@theluctus](https://xcancel.com/theluctus/status/1459287487373877248?s=21)

- <sl-card markdown="block">

  <q>Bridgetown rules.</q>

  [@middlemanapp](https://twitter.com/middlemanapp/status/1264014892673069057?s=20)


</section>
</section-wrapper>

<section-wrapper style="padding-top:2rem">
  <section markdown="1">

<p class="heading-icon">
  <sl-icon library="remixicon" name="media/speed-fill"></sl-icon>
</p>

## Build fast. Deploy fast. Serve fast.
{:.serif .colorful}

Like the Ruby language itself, **Bridgetown** is optimized for [web developer happiness](/docs/philosophy). Express yourself in code which is elegant and maintainable. Bundled configurations and resources like our [community chat](https://discord.gg/4E6hktQGz4) help you quickly get a leg up. Go from zero to hero in no time with atomic build artifacts, lightweight API servers, and rapid Git-based deployment on no-to-low-cost hosting services.


<p>
  <a href="/docs"><sl-button variant="primary" outline>
    <sl-icon slot="prefix" library="remixicon" name="development/code-box"></sl-icon>
    Install Now
  </sl-button></a>
</p>
{:style="text-align:center; margin-top:3rem"}

  </section>
</section-wrapper>

<section-wrapper>
  <section style="
    max-width: 38.5rem;
    --sl-color-warning-600: var(--color-light-orange);
    --box-shadow: 1px 3px 10px -3px var(--sl-color-danger-100), 12px 40px 35px -15px var(--sl-color-warning-50);
    --sl-panel-border-width: 2px;
    --sl-panel-border-color: var(--sl-color-orange-200);
  "><wiggle-note>

  {%@ Note type: :warning, icon: "map/map-pin-user" do %}

    Bridgetown is made possible by the generous contributions of our [GitHub sponsors](https://github.com/bridgetownrb/bridgetown#special-thanks-to-our-founding-members--). Please [consider becoming a sponsor](https://github.com/sponsors/jaredcwhite) today and support the ongoing development of open source, Ruby-first & HTML-first software projects.

  {% end %}

  </wiggle-note></section>
</section-wrapper>

<section-wrapper>
  <section markdown="1">

<p class="heading-icon">
  <sl-icon library="remixicon" name="business/stack-fill"></sl-icon>
</p>

## Super-dee-dooper features galore.
{:.serif .colorful}

Bridgetown's philosophy is if we take the time to build what you'll actually need, you won't have to. Without having to hunt for any additional add-ons or extra recipes, **Bridgetown** gives you right out of the box from day one:

{:.info-grid.highlighted-cards}
- <sl-card markdown="block">

  <sl-icon library="remixicon" name="system/settings-4-fill"></sl-icon>

  ### Static Site Generator

  All of the features you’ve grown to love from the world of static site generation. Front Matter. Markdown. Easy permalinks. File-based content deployment with Git history and atomic builds. Data transformation pipelines. Paginated archives. It's all here and ready to roll.

  <p><a href="/docs/core-concepts"><sl-button variant="primary" size="small" outline pill>
    Read the Docs
    <sl-icon slot="suffix" library="remixicon" name="arrows/arrow-right-s-fill"></sl-icon>
  </sl-button></a></p>

- <sl-card markdown="block">

  <sl-icon library="remixicon" name="document/book-2-fill"></sl-icon>

  ### Powerful Content Engine

  Set up collections for whatever types of content you need. Define taxonomies. Create relationships between different pieces of content. And when you need to, easily generate new content at build-time (or in real-time!) by connecting to a Headless CMS and other web APIs.

  <p><a href="/docs/resources"><sl-button variant="primary" size="small" outline pill>
    Read the Docs
    <sl-icon slot="suffix" library="remixicon" name="arrows/arrow-right-s-fill"></sl-icon>
  </sl-button></a></p>

- <sl-card markdown="block">

  <sl-icon library="remixicon" name="development/braces-fill"></sl-icon>

  ### World-Class Template Engine

  Actually more than one. Actually four! ERB. Serbea. Streamlined. Liquid. Start with ERB for the same familiar syntax you know from other Ruby frameworks. Or choose Serbea, a superset of ERB which brings the best of Ruby and Liquid-style templates together. Or use Streamlined for authoring complex interpolated Ruby & HTML components using heredocs. So many options!

  <p><a href="/docs/template-engines"><sl-button variant="primary" size="small" outline pill>
    Read the Docs
    <sl-icon slot="suffix" library="remixicon" name="arrows/arrow-right-s-fill"></sl-icon>
  </sl-button></a></p>

- <sl-card markdown="block">

  <sl-icon library="remixicon" name="design/layout-2-fill"></sl-icon>

  ### Componentized View Layer

  Best practices in modern web design revolve around components, discrete building blocks of visual and semantic functionality. Use Bridgetown components for a modular approach to your site design. Sprinkle frontend web components on top for that extra sizzle. Include components easily within Markdown syntax for the ultimate in text content authoring.

  <p><a href="/docs/components"><sl-button variant="primary" size="small" outline pill>
    Read the Docs
    <sl-icon slot="suffix" library="remixicon" name="arrows/arrow-right-s-fill"></sl-icon>
  </sl-button></a></p>

- <sl-card markdown="block">

  <sl-icon library="remixicon" name="device/database-2-fill"></sl-icon>

  ### Fullstack Framework

  Some projects don't need an SSR backend. But for the ones that do, Bridgetown's got you covered. It comes with Roda right out of the box, one of the fastest Ruby web frameworks in the biz. Create a view template and add a dynamic route block at the top which can handle all the requests you'll throw at it. Or craft a fully object-oriented server API. Want to connect to a database like PostgreSQL? No problem! Now that's a stack.

  <p><a href="/docs/routes"><sl-button variant="primary" size="small" outline pill>
    Read the Docs
    <sl-icon slot="suffix" library="remixicon" name="arrows/arrow-right-s-fill"></sl-icon>
  </sl-button></a></p>

- <sl-card markdown="block">

  <sl-icon library="remixicon" name="development/css3-fill"></sl-icon>

  ### Modern Frontend Build System

  Bridgetown sets you up with blazing-fast, zero-config esbuild & PostCSS. Add modern CSS starter kits and JavaScript libraries in a performant way with a few simple commands. Install comprehensive component libraries such as Web Awesome for rapid UI development. Go big with interactive functionality or stay minimalist for that “zero JS" experience. It's totally your choice.

  <p><a href="/docs/frontend-assets"><sl-button variant="primary" size="small" outline pill>
    Read the Docs
    <sl-icon slot="suffix" library="remixicon" name="arrows/arrow-right-s-fill"></sl-icon>
  </sl-button></a></p>

- <sl-card markdown="block">

  <sl-icon library="remixicon" name="business/service-fill"></sl-icon>

  ### Sky-High Plugin Architecture

  Bridgetown might just be the easiest way to get started learning and writing Ruby code. Craft custom plugins to enhance your site build and content with a straightforward DSL and make huge strides in only a few lines! And if you already have experience writing Ruby apps in other frameworks, you should feel right at home.

  <p><a href="/docs/plugins"><sl-button variant="primary" size="small" outline pill>
    Read the Docs
    <sl-icon slot="suffix" library="remixicon" name="arrows/arrow-right-s-fill"></sl-icon>
  </sl-button></a></p>

- <sl-card markdown="block">

  <sl-icon library="remixicon" name="development/git-merge-fill"></sl-icon>

  ### Sensible Deployment Strategy

  For static-only projects, you can deploy Bridgetown sites literally anywhere which supports HTML/CSS/JS files. Jamstack-style hosts are great options for performance and security. For a full-stack production setup with database access, Redis caching, and all the rest, Render is our recommended hosting platform.

  <p><a href="/docs/deployment"><sl-button variant="primary" size="small" outline pill>
    Read the Docs
    <sl-icon slot="suffix" library="remixicon" name="arrows/arrow-right-s-fill"></sl-icon>
  </sl-button></a></p>


Then when you're ready, [bundled configurations](/docs/bundled-configurations) and [plugins](/plugins) can take you even farther. Add SEO/social graph support, news feeds, inlined SVGs, asset management integration, database support, automated testing, islands architecture, Lit SSR + Hydration, and a whole lot more.
{:style="text-align:center; margin-top:3rem; margin-left:auto; margin-right:auto; max-width:50em"}

<p>
  <a href="/docs"><sl-button variant="primary" pill size="large">
    Start Your Build Today
    <sl-icon slot="suffix" library="remixicon" name="arrows/arrow-right-s-fill"></sl-icon>
  </sl-button></a>
</p>
{:style="text-align:center; margin-top:3rem"}


  </section>
</section-wrapper>
</main-content>

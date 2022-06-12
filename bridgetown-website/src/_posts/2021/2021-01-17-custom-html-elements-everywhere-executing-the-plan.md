---
title: "Custom HTML Elements and Page Layout: Executing the Plan"
subtitle: It’s one thing to claim you can take an existing website and convert it so it only uses semantic and custom HTML elements. It’s another thing to actually do it.
author: jared
category: showcase
---

{: .has-text-centered}
**“Make the plan, execute the plan, expect the plan to go off the rails…throw away the plan.”**  
– _Captain Cold_

[Last time on the Bridgetown blog](/showcase/custom-html-elements-everywhere-for-page-layout/), our intrepid web developer (that would be me 😄) boldly ripped the veil off and exposed the shocking truth that this website was—by and large—`<div>` and `<span>` tag free. For example (simplified from the production site markup):

```html
<layout-column class="column is-three-quarters">
  <h1>Jazz Up Your Site with Themes &amp; Plugins</h1>

  <article class="box">
    <a href="https://github.com/bridgetownrb/automations">
      <h2>automations</h2>
    </a>

    <article-content class="content">
      A collection of helpful automations that can be applied to Bridgetown websites.
    </article-content>

    <article-author class="author">
      <img src="https://avatars3.githubusercontent.com/u/63275815?v=4" alt="bridgetownrb" class="avatar" loading="lazy">
      <a href="https://github.com/bridgetownrb">bridgetownrb</a>
    </article-author>
  </article>
</layout-column>
```

How was such a feat accomplished? That’s the subject for today’s post.

### Time to Execute the Plan

It’s one thing to claim you can take an existing website and convert it so it only uses semantic and custom HTML elements. It’s another thing to actually do it.

As I reviewed the usage of various div/span tags on the site, I quickly realized I would need to figure out a way to remember which tags I had already defined as I go along. For example, if I were to convert `span` in particular contexts to something like `ui-label`, I’d have to remember to use `ui-label` again in similar circumstances and not make up something else like `widget-caption`.

So one of the first things I did was create a new stylesheet called, appropriately enough, `custom_elements.css`.  And then, one by one, as I went through every template in the website repository, I would add the elements to this one file. Here’s a snippet from the Bridgetown website:

```css
article-author,
article-content, /* .content */
img-container,
layout-columns, /* .columns */
layout-notice,
layout-spacer,
main-content /* .content */ {
  display: block;
}

ui-label {
  display: inline;
}
```

Basically this ensures a bunch of custom elements behave the same as using a div (`display: block`). In addition, while custom elements are `display: inline` by default, I wanted to enforce and remember the purpose of the `ui-label` element, so that’s included as well.

I also added comments to indicate that some elements have a 1:1 class name correlation with the CSS framework used by the Bridgetown site (Bulma). If I were writing a stylesheet from scratch, I could hang properties off of an element name selector itself, but on this site I have to work within an existing class-based framework.

But that’s not all. There are also some elements with 1:1 class name correlations that have their own `display` properties set by Bulma classes, and I didn’t want to redefine those in my own stylesheet. So I created an additional comment block at the bottom of `custom_elements.css`:

```css
/*
# Class names to use for these elements:
button-group = .buttons
layout-box = .box
layout-column = .column
layout-sidebar = .column
nav-inner = .container
nav-menu = .navbar-menu
nav-section = .navbar-brand, .navbar-start, .navbar-end
ui-icon = .icon
*/
```

Now anytime myself or another contributor is wondering which custom elements to use where, or which class names to use for which element, there’s an obvious reference guide available.

### How Do You Verify Element Names?

This raises an interesting question: how do you make sure you haven’t added elements and forgotten to include them in the CSS comments? I encountered this conundrum right away, and the solution is simple: **use regex**!

```
<[^ !>]*?-
```

In your text editor, search using this regular expression and it will find _all_ HTML tags with at least one hyphen. Then you can quickly scan through your templates and make sure you didn’t miss anything.

It’s also a good way to double-back and refactor if you end up deciding on a new element name for a particular use case. 

### How Do You Come Up With Useful Element Names?

If you look at the kinds of names I arrived at during this process, many of them are derived from the parent tag they are associated with. For example, `<main>` is a builtin HTML5 tag, so `<main-content>` implies that it contains a subset of the markup within `<main>`. Similarly, tags like `<nav-inner>` and `<nav-menu>` are for use within `<nav>`, `<article-author>` within`<article>`, etc.

Other names are descriptive of the _category_ they represent, for example all the `<layout-*>` and `<ui-*>` tags.

Something that’s important to reiterate is you shouldn’t create a new custom element lightly. Double-check there isn’t a standard HTML element already available. For instance, I don’t need to come up with custom elements to represent headers or footers because HTML already has `<header>` and `<footer>` tags.

### What About Web Components?

One obvious area for future improvement is to identify which custom elements could possibly be replaced with bona fide web components—either something I write or something already available on NPM. For instance, instead of using `<button>` tags and then needing `<ui-icon>` and `<ui-label>` within the buttons (all using Bulma CSS classes), perhaps I could switch to using `<sl-button>` web components instead ([provided by the Shoelace library](https://shoelace.style/components/button)).

As already explained in [Part I of this series](/showcase/custom-html-elements-everywhere-for-page-layout/), web components are by nature custom elements, but custom elements are not web components (unless you upgrade them via JavaScript). So it’s actually not a bad practice to start out with basic markup using custom elements, and then “upgrade” to using a web component if and when the need arises.

### Linter Optional

Also mentioned in Part I, I installed [linthtml](https://github.com/linthtml/linthtml) to enforce a rule of not allowing div/span tags in the codebase. Running this linter was very helpful for finding and correcting all the violations. I’m not necessarily recommending you should take such a drastic measure in your codebase. There’s certainly nothing “wrong” with using div/span tags. I simply felt like it would be a worthwhile exercise to see if you could actually write modern HTML using _only_ builtin semantic or custom elements for the entire website. And the answer of course is: **yes you can!**

### Conclusion

While it was certainly a chunk of effort for no obviously noticeable gains, I remain very satisfied with the end result of this project, and it’s completely changed how I think about writing HTML and CSS for my websites and web applications. While it’s premature to say I’ll never reach for a `<div>` or a `<span>` again, what I can tell you is that it’s quickly becoming habitual _not to_. And I think that’s a wonderful testament to just how powerful and expressive HTML can be today.

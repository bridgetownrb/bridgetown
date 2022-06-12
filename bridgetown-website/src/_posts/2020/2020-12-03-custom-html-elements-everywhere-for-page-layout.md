---
title: "Custom HTML Elements and Page Layout: Past, Present, and Future"
subtitle: Nobody ever got fired for adding a div tag to a React component or an ERB template or a WordPress theme. But there is a better way. Welcome to the modern web of custom elements everywhere.
author: jared
category: showcase
---

As we prepare to enter the year 2021, allow me to make a bold statement: it's totally unnecessary—perhaps even an anti-pattern—to use `<div>` and `<span>` tags in your HTML.

_Now before you shake your fist at your smartphone or computer screen and write me off as a veritable nutcase_, let us briefly review the history of HTML.

### How We Got Here

HTML stands for "HyperText Markup Language". It was originally designed as a text format for sharing academic materials. It had virtually no styling abilities, and in fact didn't even ship with a proper image tag.

Throughout the 1990s, as Netscape rose to prominence and the internet transitioned from higher academia to the public stage, the race was on to make HTML ever more capable in terms of visuals and interactivity.

HTML gave way to DHTML—Dynamic HyperText Markup Language. Netscape had their own idea of how DHTML should work, called [the LAYER tag](https://web.archive.org/web/20040113053043/developer.netscape.com/docs/manuals/communicator/dynhtml/index.htm). But that tag never achieved widespread adoption and instead we ended up with a potent combination of CSS and…the DIV tag.

From the HTML4 introduction to DIV and SPAN dating from 1999:

> The DIV and SPAN elements, in conjunction with the id and class attributes, offer a generic mechanism for adding structure to documents. These elements define content to be inline (SPAN) or block-level (DIV) but impose no other presentational idioms on the content. Thus, authors may use these elements in conjunction with style sheets, the lang attribute, etc., to tailor HTML to their own needs and tastes.
> 
> Suppose, for example, that we wanted to generate an HTML document based on a database of client information. Since HTML does not include elements that identify objects such as "client", "telephone number", "email address", etc., we use DIV and SPAN to achieve the desired structural and presentational effects. We might use the TABLE element as follows to structure the information…

While it's true you could use `<div>` tags in the late 90s, it was slow going in terms of page layout because of the limitations of CSS itself. Many website designs used tables instead, or even resorted to proprietary plugins such as Flash.

But eventually the industry transitioned away from tables, Flash, etc. to "float-based" layouts (and since flexbox and grid)—and the tag most commonly used to hang styles off of remained the most generic tag of all: DIV.

_However_, that's not the end of our story! Concurrent with the developing power of CSS to handle complex page layout was the development of **XHTML**. Everyone in the decade of the 2000s went bananas over XML, and the web community was no different. XHTML was a change that saw HTML switch from being based on SGML (Standard Generalized Markup Language) to being based on XML (eXtensible Markup Language). XML was envisioned as providing a newer/easier/better method of defining new document types/schemas than its predecessor SGML, and one of the benefits of XML provided to XHTML was the ability to mix in other XML schemas. In other words, _you could extend HTML itself._ (Read this [W3C documentation on XHTML modularity](https://www.w3.org/TR/2008/REC-xhtml-modularization-20081008/introduction.html#s_intro_hybrid).)

Yes indeed, you could add new elements to XHTML using externally-defined DTDs (Document Type Definitions), turning HTML itself into nothing more than one building block among many other building blocks for a bigger, more expressive, more structured, _semantic web_.

**Only that never happened.**

XHTML was eventually rejected as _The One True Path Forward_ for the web. In its place, we got HTML5, and HTML5 defined the decade of the 2010s.

HTML5 eventually did away with all its past XML-ness and instead concentrated on making HTML as balanced as possible between familiarity and expressiveness while establishing a clear process for cross-browser collaboration going forward in many related areas (namely, CSS & Javascript).

Unfortunately, in weaning web developers back off of XML, the modular nature of XML largely was lost, and thus enthusiasts of expressive, semantic markup were relegated to the fringe edges of hypertext theory.

**Or were they?**

### Introducing Custom Elements

While everyone was rocking their DIVs and SPANs for accomplishing, well, pretty much anything and everything in HTML page layout, a curious new spec emerged—largely in parallel to HTML5 itself.

First drafted in 2013, the Custom Elements spec defined how browsers could "upgrade" a custom element (recognizable by its hypenated nature…i.e. `<my-tag>`, rather than simply `<tag>`) and provide it with special interactive powers. The curious thing about the Custom Elements spec is it basically just talks about Javascript and hardly touches on the HTML side of things itself. Why is that?

_Because browsers already allowed virtually unlimited tag names!_

Sure, it wasn't "valid" HTML by any means, and you might occasionally run into the odd side-effect, but because browsers were always very liberal about how they interpreted an HTML document, there wasn't really anything stopping you from using `<paragraph>` instead of `<p>` or `<navbar>` instead of `<nav>`.

Nevertheless, the Custom Elements spec officially "blessed" the usage of custom elements and provided them with full Javascript-based lifecycles. As long as you have at least one hyphen in the tag name, you're golden. Over time, that spec evolved into the advanced Web Components spec now supported by **all** modern browsers.

What apparently has been lost on many web developers is: _you don't need to use Javascript to use Custom Elements_. It's **optional**.

That's right, all that's required to add a custom element to your HTML5 document is…to add it. 😄 Here's how you do it:

Take a bare HTML5 page:

```html
<!doctype html>
<html>
  <head>
    <title>My HTML Page</title>
  </head>
  <body>
  </body>
</html>
```

and add `<text-greeting>Hello World!</text-greeting>` as a child of `<body>`.

```html
<!doctype html>
<html>
  <head>
    <title>My HTML Page</title>
  </head>
  <body>
    <text-greeting>Hello World!</text-greeting>
  </body>
</html>
```

Congratulations! You've just added a custom element to your page. _No Javascript required._ No need to add `customElements.define` anywhere. It's simply not necessary. (Unless you actually want to write a bona fide web component.) You can style your custom element with CSS, query it and manipulate it with vanilla Javascript, and use it in basically any web framework.

### Er, So What the Heck is Special About DIV Then?

The only obvious difference between a custom element and a `<div>` tag is that custom elements are styled `display: inline` by default, just like `<span>`. So in that sense, your use of `<span>` and a custom element is completely interchangeable.

To make your custom element behave like a `<div>`, simply style it with `display: block`, and _voila_! Now your custom element is equivalent to `<div>`. It's that simple.

Also, unless you do use the custom elements registry and define a web component, a custom element will be of the `HTMLUnknownElement` class in Javascript instead of `HTMLDivElement` or `HTMLSpanElement`. That's pretty much it.

So…if all this is true and custom elements are completely valid in all modern browsers without any Javascript required…then why on earth are we stuck writing 90s-era DIVs everywhere?! It's semantically meaningless and only serves as a raw vessel for styling purposes!

The answer is…inertia and ignorance.

Everyone's already been trained to use `<div>` and `<span>` tags everywhere, so that's just what we do. It's what everybody does. Nobody ever got fired for adding a `<div>` tag to a React component or an ERB template or a WordPress theme. And if nobody tells us there's a better alternative, we'll never change!

Even within the past month, I've been in web dev chat rooms telling some **very smart people** that you can use custom elements wherever you like without Javascript, and the response is "Wait wut?? Really? Are you kidding me?!"

I don't know why all the confusion. Maybe it was terrible marketing on the part of the custom element/web component authors. Maybe it was all the deafening noise from the Big Javascript Frameworks (I'm looking at you React!) that simply don't seem to care.

But whatever the reason, I'm here to tell you that right here, right now, you can use the Custom Elements spec to your advantage and _eliminate virtually all of your DIVs/SPANs_ in favor of expressive, semantically-useful custom elements.

Don't believe me? Well, I'll let you in on a little secret:

**This website is DIV-free.** 🤯

That's right, all the `<div>` and `<span>` tags are gone. (Well, 99.9% of them anyway.) Go ahead, view source. I dare ya. Look in your dev inspector. It's custom elements (and sure, plenty of regular HTML5 elements) all the way down.

Not only that, but I installed the `linthtml` linter as part of this site's build process so that _you can't add any new DIVs/SPANs unless you explicitly bypass the lint rule_. Excessive? Probably. Unwise? Maybe. But I'm here to make a point. **It's time to ditch your ancient 90s-era markup and teleport into the future.** Custom elements (as well as web components proper) and here and _they're here to stay_. We can finally have our HTML cake and eat XML-like extensibility too. Finally.

[Keep reading for "part 2" of this story](/showcase/custom-html-elements-everywhere-executing-the-plan) where I do a deep dive into how I converted the Bridgetown website over to using custom elements along with a few neat tips & tricks along the way for organizing and styling your custom element library.

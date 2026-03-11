---
title: What is Bridgetown Center & How to Apply
---

{% data.breadcrumbs_for_layout = capture do %}
  <sl-breadcrumb style="display:block; margin-bottom:2.1em">
    <sl-icon library="remixicon" name="arrows/arrow-right-s-fill" slot="separator" style="font-size:1.2em; margin-top:0.1em"></sl-icon>
  
    <sl-breadcrumb-item href="/plugins">Plugins Directory</sl-breadcrumb-item>
    <sl-breadcrumb-item></sl-breadcrumb-item>
  </sl-breadcrumb>
{% end %}

{{ svg "/images/bridgetown-center.svg", width: "100%", height: "100%", style: "color: #561c2d; max-width:750px; margin:0 auto 2rem; display:block" }}

**Bridgetown Center** is a new community DevRel program and "seal of quality" for a choice group of plugins & themes built for the Bridgetown web framework.

It of course remains true that anyone can write a plugin or a theme (which is a type of plugin) for Bridgetown and publish it online, with the code hosted on the Git forge of their choosing (Codeberg, GitLab, and GitHub being popular options). We provide [documentation here](/docs/plugins#creating-a-gem) to help you get started, and you can file a PR in the Bridgetown repo to include your project in our [Plugins Directory](/plugins).

But if you're keen to take your efforts to the next level, and are perhaps in search of an extra degree of mentorship in the development & promotion of your plugin(s), we are pleased to offer **Bridgetown Center**. This brand-new program presents the opportunity to have an outsized impact on developers & users alike. Developers are incentivized to grow their presence and innovate within the Bridgetown ecosystem, and users of Bridgetown will be likely to gravitate towards **Center** plugins as they craft their own websites and web applications due to the justified expectation of quality.

## How the Program Works

Plugin developers who have been accepted into the **Bridgetown Center** program and benefit from its support & engagement are committed to ensuring a heightened degree of care over their published work. Such commitments include:

*   Ensuring plugins are **kept updated** within a reasonable timeframe whenever there's a new Bridgetown release which might include breaking changes (which we do try to keep to a minimum).
*   Publishing plugins using an **open source or ethical source** license. (A "source available" license broadly prohibiting commercial redistribution would not qualify.)
*   Being responsive to community feedback (questions, bug reports, feature requests, etc.), and abiding by the **Bridgetown Code of Conduct** as they engage with the community.
    *   This includes assurance the artifacts they publish (or accept in PRs) within their theme or plugin is free of AI-generated assets (aka code, written materials, artwork, etc.). We won't police anyone's personal use of Generative AI. All we ask is a good faith promise that all publicly available material in plugins & themes is created by a human.
    *   We make exceptions for traditional "ML" use cases. Just ask the core team if you're unsure about your use case!
*   Caring about the stability and UX/DX of their software. This can be difficult to quantify, but we evaluate questions like:
    *   Is the plugin easy to configure or customize in ways users might expect?
    *   Is the plugin validated to be fit to purpose via automated tests and manual QA?
    *   Does the plugin refrain from pulling in significant components of other frameworks or specialized build processes? (For example, no surprise inclusion of Active Support, or a requirement to install Tailwind.) If it's a theme, does it offer design system customization via CSS custom properties?
    *   Does the plugin respect locally-executing, free (or _libre_) computing, and refrain from calling out to third-party APIs & services unless explicitly noted and justified? (For example, a plugin integrating a hosted CMS would only function by calling the API for that CMS which is understandable, whereas a plugin to determine closely-related posts to a given post shouldn't slyly farm out text analysis to a cloud service and thereby "leak" personal data).
    *   Is plugin installation and usage documented well, with instructions written in a friendly tone?
        
And remember, being part of **Center** doesn't have to be a super long-term commitment. We can help pair developers with people who might be excited to join their projects as new maintainers to free up their time, and if necessary we can assist in offloading projects to other leads or simply remove a project from the program in the worst-case scenario.

If this sounds like a potential fit for your aspirations as a plugin developer, _fabulous!_ Keep reading to learn more about how **Center** can supercharge your efforts.


## Benefits of Joining Bridgetown Center

As part of **Center**, your projects will be enthusiastically recommended and promoted by the Bridgetown team in official marketing channels as well as during community support. For example:

*   Your plugin(s) will be featured in a special highlighted section of the [Plugins Directory](/plugins).
*   Upcoming documentation or tutorials we publish may incorporate the use of your plugin.
*   Questions from community members of how to add features or solve problems in their site builds are more likely to be addressed to preference **Center** plugins.
*   We will use our blog, social media, and other channels to feature **Center** plugins as well their maintainers.
*   In your own promotion, you can use the **Bridgetown Center Badge** to indicate to users you're a member of the program and stand by the quality and humanity of your work.

In addition, joining this program will afford you a greater degree of access to the Bridgetown core team in the form of mentorship & support as you work through issues in the development of your projects.

*   We offer a dedicated **Discord** channel and/or **Matrix** room where you can ask questions and get feedback from core team members.
*   Roughly once each quarter, we will schedule a live video conference where Bridgetown developers & **Center** participants can touch base and feel a sense of camaraderie.
*   In rare cases when changes to Bridgetown may affect plugin authors in significant ways, we will ping **Center** participants to ask for comments and suggestions.
    

## How to Apply to Bridgetown Center

The only principle requirement is that you have at least one plugin developed—either published or in a private beta stage—and you agree to abide by the rules of the program as described previously.

📋 To get started, [**fill out this form** with some brief information about](https://heyform.net/f/HYX33LNW){: target="_blank"}:

*   Why you wish to join **Center**
*   Your experience (if any) in working on open source projects
*   What degree of mentorship (if any) you may be hoping to access
*   Your willingness to adhere to the [Bridgetown Code of Conduct](https://github.com/bridgetownrb/bridgetown/blob/main/CODE_OF_CONDUCT.md){: target="_blank"}
*   Link(s) to your project(s) for our evaluation (if they are publicly available).
    
Unless there are any unexpected red flags, we are very likely to be pleased to accept you into the program!

If you have any additional questions about the program, [please ask us in our Discord or Matrix room](/community). 💬

{{ svg "/images/bridgetown-center.svg", width: "100%", height: "100%", style: "color: #561c2d; max-width:750px; margin:3rem auto 1rem; display:block" }}

<p style="text-align:center; opacity: 0.75">
  <small>
  Center iconography based upon <a href="https://phosphoricons.com" target="_blank" rel="noopener noreferrer">Phosphor</a>
  </small>
</p>

---
layout: localization
title: "Multi-locale page"
locale_overrides:
  fr:
    title: "Sur mesure"
---

{% if site.locale == "en" %}English:{% elsif site.locale == "fr" %}French:{% endif %} {{ data.title }}

{{ site.locale | t }}: {{ "test.name" | t }}

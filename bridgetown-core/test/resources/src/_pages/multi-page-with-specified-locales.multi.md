---
layout: localization
title: "Multi-locale with specified locales page"
template_engine: liquid
locales:
  - en
---

{% if site.locale == "en" %}English:{% elsif site.locale == "fr" %}French:{% endif %} {{ data.title }}

{{ site.locale | t }}: {{ "test.name" | t }}

---
layout: localization
title: "Multi-locale page"
locale_overrides:
  fr:
    title: "Sur mesure"
locale: multi
---

{% if site.locale == "en" %}English:{% elsif site.locale == "fr" %}French:{% endif %} {{ resource.data.title }}

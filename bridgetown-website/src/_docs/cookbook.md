---
order: 2500
title: Cookbook
#top_section: Introduction
category: cookbook
next_page_order: 2501
layout: docs
---

## Pagination

### Pagination Needs to be in a Collection

Pagination pages don't appear in collections. If you need your pagination page to be in a collection (like you have a menu that iterates a collection), have two pages. The first page can show the same number of entries and have a link for the other archive page in place of pagination.

### Organize a Collection by Years

The built in paginator can't do this, but it's fairly easy to do as long as you don't need a restful url for each year.

[collection_by_years recipe]('cookbook/collection_by_years')


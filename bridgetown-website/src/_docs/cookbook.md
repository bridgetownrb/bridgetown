---
order: 2500
title: Cookbook
#top_section: Introduction
category: cookbook
next_page_order: 2501
layout: docs
---

## Helpers

### General Helpers

The **cache_busting_url** from the doc using the configured url of the project, and the **multiply_and_optionally_add** example, in a single file.

[helpers_example recipe](cookbook/helpers_example)

### Date Helpers

In your project you might for example have a frequently used strftime format. Or you may run into issues with ruby having Time, Date and DateTime classes, as well as strings containing date/time values. This helper provides two methods: **standardize_date** to convert to date objects and **date_format** to format the date.

[helpers_date recipe](cookbook/helpers_date)

## Pagination

### Keeping a Pagination Page in a Collection

Pagination pages don't appear in collections. If you need your pagination page to be in a collection (like you have a menu that iterates a collection), have two pages. The first page can show the same number of entries and have a link for the other archive page in place of pagination.

### Archives by Date Period

**collection_by_years** does not use pagination at all to create a time period grouped index. Using this approach avoids the paginator.

[collection_by_years recipe](cookbook/collection_by_years)

**monthly_archives** uses prototypes, which rely on the paginator.

[monthly_archives recipe](cookbook/monthly_archives)
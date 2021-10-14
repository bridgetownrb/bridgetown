---
layout: page
title: Posts
---

<ul>
  {% for post in collections.posts.resources %}
    <li>
      <a href="{{ post.relative_url }}">{{ post.title }}</a>
    </li>
  {% endfor %}
</ul>

If you have a lot of posts, you may want to consider adding [pagination](https://www.bridgetownrb.com/docs/content/pagination)!

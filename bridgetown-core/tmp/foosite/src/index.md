---
# Feel free to add content and custom Front Matter to this file.

layout: home
---

Welcome to Bridgetown!

<h2>Posts</h2>

<ul>
  {% for post in site.posts %}
  <li><a href="{{ post.url }}">{{ post.title }}</a></li>
  {% endfor %}
</ul>

~~~ruby
{ title: "I'm a Second Level Page" }
~~~

That's **nice**.

Locale: {{ resource.data.locale }}

Other Locales:

<ul>
  {%- for other_resource in resource.all_locales %}
    <li>{{ other_resource.data.title }}: {{ other_resource.relative_url }}</li>
  {%- endfor %}
</ul>
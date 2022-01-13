---
title: Recording and Transcript of November 2021 AMA on Twitter Spaces
subtitle: |
  News updates and Q&A regarding the Bridgetown fundraising campaign and the state of web frameworks today.
author: jared
category: news
---

I recently hosted a live news update and AMA on Twitter Spaces, and it was a great success! A bunch of people joined in and I got to answer a few questions.

Topics included a progress report on the [Bridgetown fundraising campaign](https://fundraising.bridgetownrb.com), the upcoming Prismic CMS plugin, the state of web frameworks and how Bridgetown relates to developments in the Jamstack as well as interop with Rails, and the importance of a "polyglot web."

**Enjoy!** (And stay tuned for another Twitter Spaces discussion in December…)

<p id="audio-wrapper" style="text-align:center; margin-top:2rem">
  <audio controls src="https://jaredwhiteshow.s3-us-west-1.amazonaws.com/Bridgetown%20Twitter%20Spaces%20Recording%20-%202021-11-12.mp3" style="width:100%; max-width:350px; display: inline-block; border-radius: 14px; margin:0; background: #f47c3c"></audio>
</p>
<script type="module">
  // Needed to workaround weird Turbo issue

  const audioTag = document.querySelector("article audio")
  const tagHTML = audioTag.outerHTML
  audioTag.remove()
  setTimeout(() => document.querySelector("#audio-wrapper").innerHTML = tagHTML)
</script>

## Transcript

_Automatic transcription by Happy Scribe, with light edits_
{:style="text-align:center"}

So I just want to do a little bit of an overview of how things are going with the Bridgetown fundraising efforts and kind of talk about what's going on with the development towards Bridgetown 1.0, and just sort of more of a general kind of overview of what my thoughts are on the state of web frameworks today and the sort of necessary efforts we need to make to champion a polyglot web, as opposed to sort of a monoculture around JavaScript or TypeScript, which is a danger that I see looming.

So I wanted to talk a little bit about that. But first Bridgetown. So in case you're not even aware of what Bridgetown is, **Bridgetown is a static site generator growing into more of a full stack web framework as well if you need that.** It's based on Ruby, but you don't have to be an expert Ruby programmer to use it by any means.

But if you do want to start customizing your website or adding some plugins and things, you will need to know a bit about Ruby. But it's really an effort to try to bring a lot of modern thinking around how to construct and deploy a website to the Ruby community. Kind of coming at things from a very different direction. Starting out than you might find with Rails, Rails has been phenomenal as a web framework for Rubyists.

Obviously it's played a major role in propelling Ruby into the mainstream, but there's lots of things you can't really do easily with Rails or Rails isn't necessarily the best suited for to start off a project. I'll get a little bit more into that later. So Bridgetown is sort of an effort to bring some of the ideas from static site generation from the Jamstack and let that flourish in an environment where Ruby programmers can feel right at home and hopefully eventually even grow the community maybe attract people who don't really know anything about Ruby to learning more about Ruby as they're building their Bridgetown sites.

All right. So with that out of the way, **progress on fundraising**.

So just a few weeks ago, two and a half, getting close to three weeks ago, we launched a fundraising effort to try to help get Bridgetown 1.0 polished up and out the door. The goal is to reach $5000. We're just about to $2000 (actually now it's around $2500 –Ed.), and I feel like that's a pretty respectable place to be. After only two and a half weeks or so, there's some good progress there. We're definitely past the point of being embarrassed.

That's always the greatest fear of these things is you launch something you say, here's our goal, and then weeks later, it's like a tiny bit of the way along. You're like, oh, man. Well, that's embarrassing, but we're definitely past that point, which is awesome. That being said, the momentum is slowing down, start out more like a flood and then is now a trickle. So I'm asking everyone for your help, to spread the word, to tell all your friends and fellow Web developers and Rubyists that Bridgetown is a project worthy of their attention and perhaps support.

Again, I'll get into this a little bit more later. But when you look at the state of Web frameworks, a lot of frameworks have large corporate backing or are literally being funded by venture capital. And there are these very official efforts.

Bridgetown is completely a community open source effort. The work I do by and large is just work I do because I want to do it and I enjoy it. And I want to give back to the Ruby community and the web developer community. And so any help through fundraising or through GitHub sponsors just essentially goes to offset the time I'm putting in relative to client work that I do as a freelancer. I work for clients and they pay me. So if I'm not working for clients, I don't get paid.

It's as simple as that. So if I'm doing a ton of work on open source software and I'm not working for clients, I'm not getting paid. So those are just the economic realities of how open source works. So I just want to say thank you to everyone who has contributed to fundraising so far. For more information on all that, you can go to our website, which is bridgetownrb.com.

All right, with that pledge drive out of the way, I'll move on to a couple of the other topics we'll go over today and then I'll answer a few questions.

**So the next topic is there is a Prismic plugin on the way.** Prismic is a headless CMS. What that means is you can go to Prismic.

You can set up content types. You can specify all the fields you want for the content types, add images, add text, add rich text, link to documents, and MP3s, whatever you want to do. You can set up your entire content structure within Prismic, and then they provide an API that you can use to get that content out of the system and then do whatever you want with it. So typically, people use Prismic along with some kind of static site generator or web framework. So with the Prismic plugin, we'll be able to enable you to create a new Bridgetown site project, connect it to your Prismic repo, and then create all your content in Prismic, and it'll all get sucked down into your Bridgetown site, and with just a little bit of configuration, you'll have all that content available within Bridgetown.

This answers a big question that I've been asked many times, which is Bridgetown looks nice and all… **But what do I use for a CMS?** Because out of the box, Bridgetown is just using files on your hard drive or on a server somewhere in your GitHub repository. It's all file based. You're creating markdown files, you're creating HTML files, you're creating templates.

And that's great from a developer standpoint. That's awesome. That's what's so cool about all these new static site generators we have today is we have all these nice file based ways of setting up content and templates, but that's not great for content editors and anyone nontechnical, anyone on the business side of an organization where they're just like, I just want to log into a thing, put in some text, click, publish, and I'm done. I don't want to know anything about what is Markown, what are these files, what are GitHub repos? Don't confuse me with all that crazy stuff.

So this is going to be a cool solution to be able to allow Prismic CMS content authors to work on the content. And then your Bridgetown site can just pull that all in and deploy it whenever you need to publish new content. So that should be out in the next couple of weeks.

And then, of course, Bridgetown 1.0, the big release. That work continues to be ongoing. The fundraising effort is definitely helping to accelerate that. **And I'm hoping to get an official 1.0 release out the door by the end of the year, perhaps right around Christmas, to coincide with a new release of Ruby.** That would be really fun.

So exciting times for Bridgetown. All right. And then finally, kind of the last topic I want to cover before questions is **my thoughts on the state of frameworks today: web frameworks, static site generators**. What's going on out there? Because the landscape has just gotten nuts.

Just in the last day or two, we found out that Vercel has hired Rich Harris, who is the creator of Svelte and SvelteKit. That's a popular frontend framework for developing rich, reactive components and interfaces. So that is on the frontend (you can't see me but I have air quotes going on here)—that's on the frontend. But increasingly, what we're seeing is that what happens on the frontend is what drives what people are building websites out of. A lot of things are starting essentially frontend first, and then at some point down the road, you start to bolt on some kind of backend solution. And increasingly, those solutions are serverless functions or some kind of Backend-as-a-Service or GraphQL API. There's so much stuff people are looking at now for what we think of as traditional backend development, but it doesn't really look like traditional backend development.

So this is why I say, I think some people who are Rails enthusiasts don't quite understand what the competition to Rails is anymore. In the past, if you ask somebody, hey, what do you think are the top competitors to Rails? Somebody might say, oh, probably Django for the Python folks, or Laravel for the PHP folks, or maybe NodeJS Express or, I don't know, NestJS or one of the other backend frameworks for Node.

And increasingly, **I would argue that Rails top competitors are Next.js, Gatsby, Nuxt SvelteKit**—these other sort of frontend-first frameworks that you basically start out doing a lot of the UI and interface work up front, and then you start to trickle in backend-looking stuff later. You don't just start out with a traditional fullstack framework. So that's why I'm super enthusiastic about the work going on right now for Bridgetown, because Bridgetown is kind of an attempt to create what looks more like a frontend-focused framework—but in the context of Ruby, in the context of creating static sites that you can easily deploy. And then once you have the beginnings of a site—maybe you have a public site with a portfolio or a blog or a list of products or something like that, and now you want to start adding some backend-looking things. You know, the direction we're going is that Bridgetown out of the box will say, like, oh, here's where you can plug in some backend code and you can deploy that sort of at the same time you're deploying a static site, and it's all just wired up and working together. **Now you might ask, well, what is that backend technology that's in Bridgetown? So that is Roda.** Roda is a very lightweight, Ruby-based backend API framework that you can use.

You can certainly go use Roda standalone by itself, it's very simple to get started with, but what we're doing in Bridgetown is marrying Bridgetown's static site features with Roda's dynamic API features and kind of bringing it all together. So Bridgetown essentially ends up as the view layer for Roda. It's very cool. And **we'll be posting a lot more examples and tutorials and things like this as we near the release of 1.0** and then the final piece of this as well.

What if you need something even more advanced than that? What if you need to really build a big, large, sophisticated application that powers your public static site with user logins and dashboards and reporting, and all these different things that might need to be attached to your site. And the answer to that is, well, **you can actually build that in Rails too**. You can build a Rails side of your project and have Bridgetown and Rails work together. And we'll be posting a lot more about that in the coming months as well.

So getting back to the state of web frameworks, **I'm increasingly feeling like there's a significant class of websites where reaching just for Ruby on Rails doesn't really make sense**. And for a lot of people, they're just heading straight into the territory of Next.js or Gatsby or Nuxt or SvelteKit or one of these kind of JavaScript-based tools. And that makes me sad, because I don't want to see Ruby-based solutions fall by the wayside and not be relevant to a whole class of developer. So that's what motivates me a lot right now as I work on Bridgetown.

And then finally, just in general, **I think it's important for us to shout from the rooftops, as it were, the importance of a polyglot web**.

And what I mean by that is I don't want to see any one language or any one ecosystem win. I don't see the web as a zero-sum game by any means. I don't want to see JavaScript or TypeScript win. I certainly wouldn't say Ruby should win or Rust should win or Go should win or any other language. Right? The web started out essentially as a platform that could be used on any platform, and you could use any language to generate HTML and serve up HTML.

And I think we really need to help people realize how important that is and not just kind of let JavaScript as the de-facto language win because that's expedient or easy to do. That being said, I'm certainly not anti-JavaScript by any means. There's actually a lot of cool stuff happening right now on the frontend with web components, with tooling like Lit which I'm super excited about, a lot of the neat stuff that's in Hotwire technology is, of course, frontend-related like Stimulus & Turbo.

The conversation isn't: do you love JavaScript or do you hate JavaScript? It's what kind of web do you want to build? Do you want to build a polyglot web where there are lots of languages you can use to generate your HTML? And then maybe you write some JavaScript for frontend components, or maybe you use a language that can transpile to JavaScript so you don't even write JavaScript per se on the frontend either. I just think all the options should be on the table and we should encourage that.

All right. I think that is it for my spiel. Now comes the time when I figure out how to take your questions.

**[Question from Andrew]**

Yeah, that's a great question.

I just answered a similar question the other day, and what I said was we really need more people testing. Testing. Testing is super helpful to me. So, yeah, I encourage anyone to install the latest Bridgetown 1.0 alpha, try to create a new site, play around with things a little bit, and if you run into any problems, if you have any sort of questions or something in the docs, we're working on better documentation for 1.0. Essentially any feedback is super helpful right now.

There's nothing like hammering away on the actual code and trying to use it to reveal any bugs or problems that we need to fix. So that's probably the biggest thing.

All right. Jacob is up next.

**[Question from Jacob]**

Thanks, Jacob, for that question. So, Bridgetown, and how it compares to Jekyll, this is one of those areas where I've had to tread carefully and haven't always got it right, because on the one hand, I certainly want to discuss in length all the things I think are exciting about Bridgetown and how it improves upon Jekyll, I would say, but I know there are still a lot of Jekyll fans out there, and I don't want to ruffle people's feathers if they're happy with something they've built using Jekyll.

So what I would say is Bridgetown starts out with what I think is Jekyll's crowning achievement, which is this idea that you can just create a Markdown file, put some front matter up at the top with your metadata, type a command, and you have a website built. Jekyll really was a pioneer in that space before. There weren't really many other options like that.

So hats off to that really nice way to onboard getting a website project started. Where I think Jekyll has languished is just not really providing very good APIs for Rubyists. You can create your own Jekyll plugin, but there's not a lot of documentation. It's kind of hard to figure out. The API is really sparse, and the platform that Jekyll has been married to for quite a while, which is GitHub Pages doesn't support any custom plugins, so that's kind of been its Achilles' heal for a while. So one of the things we're trying to do in Bridgetown is create lots of really nice APIs that are maybe a little bit more influenced by Rails to make it easy to write plugins, to make it easy to use Ruby-based template languages such as ERB.

We have recently introduced the idea of Ruby-based components so you can write your own components. And that's really like a Ruby file and a template that goes along with that Ruby file, and you can construct all of the HTML on your site out of sort of a graph of components. And if you have any familiarity with ViewComponent by GitHub for Rails, it's very much like that. And in fact, we actually have a compatibility layer so you can use ViewComponent in a Bridgetown site, which is kind of bananas, but also kind of awesome.

That's possible.

Now I would just say Jekyll versus Bridgetown, you're going to find with Bridgetown that it leverages any Ruby knowledge. You may have a whole lot more, but you also can do things that are very simple. Just create a Markdown file and stick a couple of Liquid tags in there and you're done. It definitely supports that as well. So the goal is to start out as simple and as easy as Jekyll, but to kind of scale up with your ambitions a lot farther.

**[Question from ?]**

Initially Bridgetown was simply a labor of love. I wasn't even intentionally trying to raise funds to work on it, but then I was encouraged by a few folks, including Andrew Mason, who is here. Hi, Andrew! I was encouraged to start a GitHub sponsors program, and I was almost reluctant at first because I didn't want this to feel like a commercial enterprise. I really wanted to be in the spirit of open source, but I decided to try it out and was very pleasantly surprised by how well that started to go, and I started to honestly rely on that little bit of side income to help me carve out more time in my schedule to work on Bridgetown.

When plans really started to solidify for getting Bridgetown 1.0 out the door, I was increasingly realizing that I'm going to have to spend really a lot of time and a lot of concentrated time to really get this release solidified and polished up and out the door. There are other contributors to Bridgetown. I'm not the only person on our core team, but I'm the primary contributor, so it's up to me to just put in the time to sit down and literally write code and test ideas. So again, someone else, not myself, encouraged me to think about starting a fundraising campaign, and that seemed like a legit idea because it's not an open ended thing forever per se.

It's just for this effort right now, as the site says, the goal is to raise enough funds to essentially provide me with a block of hours.

And in those hours, I can work on getting 1.0 done and out the door. Yeah. And I'll post something a little bit down the road, too, about just the technical aspect of setting up the site itself, because I'm eating my own dog food here. The fundraising site is a Bridgetown site, and it supports three different kinds of payments. You can actually click over to GitHub sponsors and pay through that, which is just a simple link.

But then there's PayPal, which requires a bit of an integration, but only on the frontend. And then there's Stripe, which is both a frontend and backend integration. So I'm actually using Bridgetown's Roda integration to handle the private Stripe key kind of stuff you have to do on the backend. So it was kind of interesting just putting that project together technically, and I'll share all that soon in a blog post.

All right. Looks like one more question here from Ivy. So take it away.

**[Question from Ivy]**

Yeah, that's a good question. "Non-goals." I would say that I'm very much influenced by the Rails philosophy and what I mean by that is convention over configuration. Really trying to focus on a happy path for a developer…don't necessarily give them too many options at first. It's always a tricky balance. Right?

Like, on the one hand, you want a system that's infinitely extensible, and it'll work on every platform, and it'll work in any hosting environment—just an endless list of options and possibilities. But there are real downsides to that. And so for me, working on Bridgetown, I'm constantly trying to imagine a singular experience that's really ideal for a developer. So kind of focusing on using a particular version of Ruby and using a particular OS and deploying to a particular web host. And it's not that we're only going to limit ourselves to supporting those, but to really kind of focus on what's the primary recommended way to build a Bridgetown site and deploy a Bridgetown site and really focus on that.

So from a standpoint of tutorials and examples and things like that, and if someone really knows what they're doing and they're saying, well, I don't want to deploy my site using Render. I want to build it over here in this Docker container, and then I want to upload that to Amazon S3, and then I want to set up Cloudfront to be a CDN…. If you want to do all that, that's awesome. But that's not what we're going to recommend. That's not what we're going to write a tutorial about. Right?

So a non-goal is kind of like, well, here's a tool, figure out how to use it, figure out how to deploy your site. Here are a million options for you. I would say no to that. But at the same time, we don't want to create something that's too confining. So there's definitely a balance there.

**[Question 2 from Ivy]**

Yeah. Another great question there. It sounds like what you're looking for maybe is what are some good use cases? What are some good industries or approaches to building websites that are an inspiration for Bridgetown that you can use Bridgetown for? And I would say over the years, certainly quite a few years ago, for me, it wasn't just developing Web apps per se. I was developing websites, and they are primarily informative, educational and so forth.

And at the time, for a little while there, I was just using WordPress, and obviously WordPress is its own behemoth in our industry. In some respects, any web framework or any technology used to build websites, its primary competitor is probably WordPress. I hate to say it, but it's true.

So in that respect, I have some background there thinking through what message are you trying to convey to an audience? How are you going to motivate them? How are you going to get them excited about what you're selling, what you're building, what you're writing, whatever it is you're trying to promote. And so sites like that maybe look like blogs, maybe look like portfolios, certainly ecommerce, landing pages for new services, publications where there's maybe a podcast and a newsletter and some different things you're trying to promote, in addition to just a post on something.

And so those are all the kind of sites I've built in the past, and it was always a question of what tool do you use for that? Do you use WordPress? Do you use some kind of hosted solution like Squarespace? Do you use a static site generator like Jekyll or 11ty or one of these new fancy ones?

Endless possibilities right? So looking at Bridgetown again, the goal is to provide something where you can start out one of these kind of website projects with just an idea, like I have a product to sell. I have a message to get out. I want to promote a podcast. I want to promote a newsletter.

I don't know. I want to show up a cool graph of a bunch of data I've collected about some interesting topic and let you start out with that idea and build something quickly. But do that using the Ruby language as sort of a base of that because I love Ruby, and I think Ruby is awesome in many ways, specifically for web developers. So I want to see that kind of tool out there on the market. And so that's what we're working on.

**[Question about Remote Ruby]**

Well, I'm part of the Andrew Mason fan club, as I know many of you are out there. So what can I say?

Actually, I have to say Bridgetown had barely started as a thing when I managed to get in touch with Chris Oliver, and right away he was just like, hey, come aboard Remote Ruby and tell us what you're working on. And I was kind of floored by that. So shout out to Remote Ruby for just being so approachable and welcoming to anyone in the community. And it's really a great resource. Cool.

All right. Well, if there are no other questions, I think we can wrap it up for today. I'm actually once again floored by the fact that the Spaces feature here actually worked and a bunch of people showed up. So this is awesome. I'll definitely try to do this again, maybe once a month, at least.

So people have an opportunity to share ideas or ask questions. And also, of course, we do have a Discord chat. If you go to bridgetownrb.com and scroll down to the footer there or click over to our community page, you can get a link to our Discord chat, and that's a great way to just ask questions, get help.

Sometimes it's not even about Bridgetown. People have come on asking questions about CSS or how to use some kind of JavaScript library or just any number of things. And usually somebody there is trying to help out and provide some answers and kick ideas around. So that's been really cool as well. Alright. Without further ado, thank you all for tuning in and I will end the space.

Now have an awesome day, evening, wherever you are. And I'll see you next time!
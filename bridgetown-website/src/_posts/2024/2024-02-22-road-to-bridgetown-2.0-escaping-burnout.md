---
date: Thu, 22 Feb 2024 09:20:27 -0800
title: Road to Bridgetown 2.0, Part 1 (Stuck in Burnout Marsh)
subtitle: In 2023 I very nearly walked away from Ruby. But after time to think and reflect, I arrived at a plan to make working on Bridgetown “fun” again. Now a new day dawns, and the ecosystem is poised to enter the next stage of this journey.
author: jared
category: future
---

**TL;DR:** Bridgetown 2.0 is now under active development! We have a new [Community discussion site](https://community.bridgetown.pub), based on Lemmy! Stay tuned for additional announcements coming soon of what’s next for the ecosystem! And now, on with the post…

----

A little known area of Bridgetown, upriver from where the tourists typically spend their time on vacation, is a treacherous stretch of water known as Burnout Marsh. My boat got mired there during the back half of 2023, and I barely escaped with my life.

All right, enough of that clumsy metaphor. 😄 I didn’t want to have to write this post, believe me. I’d much rather just get on to all the juicy technical stuff that’s fun to talk about. Blog posts about “maintainer burnout” are as exciting to read as watching paint dry. It’s a bit akin to the celebrity complaining about how they have to hire security because they’re just so gosh darn famous. Like, dude, you’re famous OK? Quit yer whining before you look like an asshole.

But the fact remains that maintainer burnout _is_ a thing, and it affects a lot of open source software projects. Everyone’s burnout looks a little different, and mine was no different in that way. A little bit of this (weird, weird time in the tech industry), a little bit of that (too many other irons in the fire), but mostly a particular thing (to be revealed momentarily) which affected the worst possible facet of my role as a maintainer of Ruby-based software: _my love of Ruby_. 😱

Truth be told, **I nearly walked away.** 😞

And the reason is both complex and simple. Here’s the simple version: the social degradation of 37signals in general and David Heinemeier Hansson (DHH) in particular nearly robbed me of all the joy I felt programming in Ruby. 😬

Now nearly as distasteful to me as wallowing in “maintainer burnout” territory is wallowing in “framework authors taking potshots” territory. So you can imagine I’m _doubly_ not feeling great about where this is headed. I’ve written some version of this post over and over again in my head, and more than once in my drafts folder which _you’ll_ never see let me tell you right now. But like ripping off a Band-Aid, some things just have to be done. So here it goes.

### The 37signals Problem

I was aghast when the meltdown at 37signals happened in 2021. It was widely covered at the time, perhaps best by Casey Newton in several pieces such as [Behind the controversy at Basecamp](https://www.theverge.com/2021/4/27/22406673/basecamp-political-speech-policy-controversy) and [Inside the all-hands meeting that led to a third of Basecamp employees quitting](https://www.theverge.com/2021/5/3/22418208/basecamp-all-hands-meeting-employee-resignations-buyouts-implosion). At the time, I thought _surely_ there would need to be some reckoning with how DHH conducts himself within open source projects as well such as Rails and Hotwire. Perhaps Rails could set up a more transparent governance structure, or at the very least announce DHH stepping down from a position of influence for a while (while making a very public stand around proper Code of Conduct (CoC) etiquette).

Not only did none of that happen 🤨, but DHH made a _huge_ stink about not being properly invited to keynote RailsConf again right away, leading to [RailsConf and DHH going their separate ways](https://thenewstack.io/railsconf-and-dhh-go-their-separate-ways/) and the eventual formation of the “Rails Foundation” and Rails World conferences. So…no such reckoning. DHH would maintain an iron grip on Rails indefinitely (this new foundation really just solidifying his personal influence rather than offering any sort of real check on his power or ego), and in fact go forward to “compete” with RubyCentral and RailsConf. 😩

As if this wasn’t all bad enough, the next shoe to drop dropped…and in a very public way as these things are wont to do. Out of the blue, without warning to any regular contributors or other community members, 37signals (aka DHH) simply decided to remove TypeScript from the Hotwire Turbo codebase. Again, no opportunity for discussion, no time for a heads up or any sort of guidance on how it might affect existing contributions. Just **boom**, here’s the PR, insta-merge within hours, [self-congratulatory DHH post on HEY World](https://world.hey.com/dhh/turbo-8-is-dropping-typescript-70165c01), done. 😳

Folks, **this is not how you run an open source software project**. Somebody’s hobby project on GitHub that’s really just their own little playground, sure, I guess. But not something as consequential as, oh I dunno, _the frontend stack of the Ruby on Rails framework_ and a tool used even outside of Rails by other frameworks! 🤪

Note carefully that none of what I’m saying or about to say has any bearing on the _merits_ of removing TypeScript. We can debate those merits at our leisure, and anyone who knows me knows I’m no big fan of TypeScript. But that’s not what this is about. This is about how people govern open source projects and conduct themselves among peers.

Needless to say, this move to unexpectedly rip TypeScript out of Turbo generally went down like a lead balloon, and things got heated fast. That’s never a good sign (when long-time regular contributors to a project are themselves feeling pretty grumpy), and it eventually led to this seminal issue: [Remove DHH for CoC Violations · Issue \#977](https://github.com/hotwired/turbo/issues/977).

To be very clear, nobody’s claiming that making the decision to remove TypeScript was a CoC violation, but the _manner_ in which it was done: with _zero_ involvement of the community and no consideration whatsoever (active hostility in fact) of broad feedback about the decision. I want to quote DHH’s posted response to this claim of CoC violation in full, because there simply is no way for me to read this without feeling enraged once again, and I want you to feel enraged too:

> “This is elevating a disagreement of a technical decision to a level of nonsense that has no place here. This project has been founded, funded, and maintained predominantly by the resources and investment of 37signals. We will set the direction as we see fit, accepting input and contributions as they're presented, but with no guarantee of concurrence or merging. All the best finding a project that's more to your liking in direction or leadership or otherwise somewhere else 👋”

Notice all the very specific language DHH employs here:

* “nonsense” — regular readers of his blog know this to be code for “woke lefties” who would dare challenge his alt-right “edgelord” positioning on a variety of topics. Every time DHH’s political machinations are being publicly challenged, you’ll see the accusations of “nonsense” trotted out ([here’s but one example](https://world.hey.com/dhh/may-shopify-s-immunity-spread-to-the-whole-herd-7bd855ce)…stochastic terrorism is “nonsense” in DHH-speak, a product of “woke scolds”).
* “founded, funded, and maintained by…37signals” — in other words, you, dear contributor to the Turbo repo, don’t actually matter if you aren’t specifically part of the business entity known as 37signals. This is technically open source, sure, but the benefits mostly flow in a single direction. 37signals gets all the benefits of _your_ efforts to improve _their_ codebase, yet meanwhile you get none of the power. Yes, you get to use their code in the end, but that’s it. That’s the only benefit. _Whoop-dee-frickin’-doo._
* “We will set the direction as we see fit” — and by “we” he means himself. DHH. The big kahuna.
* “All the best finding a project that's more to your liking” — aka if you don’t like how I run things, _fuck you_.

Folks, there are times when situations are complicated, nuanced, with no real good guys or bad guys, and it’s genuinely hard to parse out what’s really going on and how to process the myriad of factors in order to arrive at a comprehensive decision.

**This is not one of those times.** 😅

Clearly what we witnessed in this debacle is _far_ from a shining example of how one should govern an “open source” project. Perhaps it would be better described as “source available” — use the code, but don’t count on the stewards of the code to care for the needs of the community. And to get real specific, I am convinced that yes, DHH has indeed been in violation of his own CoC, and the real tragedy is _nobody has the power to call him on his own bullshit_. DHH is co-owner of 37signals, and 37signals controls all Hotwire intellectual property.

Personally, I find DHH’s continued stranglehold over the Rails and Hotwire frameworks nauseating and thoroughly unacceptable. But ultimately, that’s not the hardest part of it for me. It’s all the carrying water for him that’s gone on in the broader community. People—and yes, good people all—still keep promoting Rails (and Rails World), keep releasing Ruby code and educational resources that prop up Rails as much if not more so as Ruby, and essentially keep DHH on his pedestal.

**It’s enough to make you just want to up and quit Ruby.** Which I very nearly did. 😭

But, y’know, I gave myself lots of time to think and reflect. I chatted a lot with my close friends and fellow Bridgetown team mates. I mused on ways I might be able to make Bridgetown “fun” again, both in terms of ongoing maintenance as well as future feature development. I waited to see if maybe I could get my boat unstuck and past Burnout Marsh and start heading downriver towards calmer waters again.

**And now I’ve arrived here.** 😌

----

### What’s Next for Bridgetown in 2024

This post kicks off a short blog series outlining some of the approach we’re taking to construct the next major release of Bridgetown, version 2.0. But it’s also an announcement: we have a new [Community site](https://community.bridgetown.pub) y’all! 🙌

Part of my general burnout in 2023 was just dealing with the absolute insanity which seems to have taken over the computer industry…not the least of which is the rapid “enshittification” of commercial social networks. It really got me paranoid—not only worrying about which services were actively going sideways (*cough* Reddit *cough*) but which might implode next in the future. Bridgetown has relied heavily on Discord, and to a lesser extent GitHub Discussions, and, well, I’ve been growing increasingly antsy about each.

So rather than wait for more shitty developments and scramble to react to them, I decided to be proactive and set up a new [Bridgetown Community site](https://community.bridgetown.pub), based on Lemmy. This serves as a replacement to GitHub Discussions, and an adjunct to Discord. We’ll still rely on Discord for chit-chat (at least until something can serve as a truly suitable substitute) but look to the Community site for longer forum-style posts, technical conversations, tutorials, and something “bloggy” that’s a bit less formal than posting here on the main blog. There are some interesting tidbits there already, and I look forward to more folks in the Bridgetown ecosystem commenting there going forward!

So let’s wrap up with a brief mention of what we’re announcing today as part of the “Road to Bridgetown 2.0” push. If you read my diatribe above, what I’ll say next probably won’t come as much of a shock.

**We’ve begun the process of de-37signals-ifying Bridgetown.** (Now there’s a mouthful! 😆)
 
Here’s what this means. We have put an immediate stop to integrating any more dependencies run by 37signals in Bridgetown. In practical terms, this means no additional embrace of libraries like Active Support, and no continued investment in bundled configurations such as Turbo or Stimulus (in fact we’ll be removing these for Bridgetown 2.0). And over time (this will be very much an incremental thing), we will either _remove_ our internal dependency on Rails libraries like Active Support or _vendor_ specific code we can’t easily replace.

This is certainly not ideal. The Bridgetown codebase, and community at large, has benefited from the features provided by Active Support, Turbo, and other 37signals-run projects. But as DHH so emphatically put it, “all the best finding a project that's more to your liking in direction or leadership or otherwise somewhere else 👋”. So that’s _exactly_ what we are doing. We’ll be looking at other libraries — or in certain cases just building our own solutions — to replace the functionality we had relied on from 37signals. 

We take Bridgetown’s own [Code of Conduct](https://github.com/bridgetownrb/bridgetown/blob/main/CODE_OF_CONDUCT.md) seriously, and part of that approach means we need to be careful we don’t pull in third-party dependencies from open source projects which are themselves in violation of _their_ CoCs. We’re not in the business of policing the internet, nor can we ever vouch for all other open source projects we might ever touch in some way. But it was a _strategic decision_ originally to embrace codebases run by 37signals, and it is another strategic decision to let them go. I’ve talked about this at length with the rest of the Bridgetown core team, and we are in agreement that it’s in the best long-term interests of the Bridgetown project to take a public stand on this.

So that is merely one aspect of the work that’s ongoing as we head towards Bridgetown 2.0. But thankfully, there’s a lot more that will no doubt prove more exciting and hopeful, from a minimum requirements bump to Ruby 3.1 and Node 20 to a _huge_ performance boost in development in the form of Signals-based Fast Refresh. More on that in the next blog post.

The big takeaway is that I’m feeling more pumped about the future of Bridgetown than I have in many months. Between sorting out feelings of disappointment around past events, and coming up with a list of improvements to the project and the ecosystem I’m very excited to be moving forward on, a new day has dawned. 🌞

**Bridgetown 2.0 represents a sort of clean break**, not just because we can remove deprecated APIs, streamline aspects of the codebase, and improve features in ways that will help make the framework faster and more stable, but because version 0.x represents an experiment, 1.0 represents something stable yet still new, and 2.0 represents _longevity_. Bridgetown is here to stay. We have a full major version bump looming. And we hope you’ll stick around to see what comes next. 🤓

_Want to discuss this post? [Jump over to our Community site and add your comment](https://community.bridgetown.pub/post/11)_ 🔗
{: style="text-align:center; margin-block-start: 1.5lh"}

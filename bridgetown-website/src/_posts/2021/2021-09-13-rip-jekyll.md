---
title: Jekyll and the Genesis of the Jamstack
subtitle: "Let's look at some positive developments that will provide a path forward for Jekyll users."
author: jared
category: future
exclude_from_pagination: true
---

**September 15 Update:** There's been a fair amount of internet consternation since I published this article. While I do stand by everything in the post factually-speaking, I apologize for the insensitive timing of this article—coming so soon after Frank's passing. I'm genuinely sorry this came across as a "Jared vs. Frank" debacle. Should I have waited a few more weeks or months? Probably. Perhaps it was originally a mistake for me to refrain from publicly commenting on the statements regarding Jekyll's "permanent hiatus" back in May. It's hard to say. At the very least, I hope we can all agree that Jekyll's legacy as the "first among many" of modern static site generators is meaningful to a lot of people, even if we sometimes disagree on the best way to honor that legacy and push Ruby on the Jamstack forward. If the one thing that comes out of all this is that more people step forward to share their positive experiences with Jekyll, Ruby, and building websites, that's a good thing.

----

## Original Article as Published:


{:style="text-align:center"}
"I can tell you there's no secret plan to revive Jekyll from the dead." ([source](/images/Screen Shot 2021-05-14 at 11.13.31 AM.png))  
"Jekyll is in frozen mode and permanent hiatus. RIP Jekyll 2009-2018." ([source](/images/Screen Shot 2021-05-14 at 11.11.01 AM.png))  
"Good luck to Jared White to build a modern SSG for the Ruby community."  

{:style="text-align:center"}
—_Frank Taillandier, (late) release maintainer of Jekyll (known as DirtyF on GitHub)_

{:style="margin-top: 2em"}
Those comments were posted in May 2021 by Frank Taillandier in [The New Dynamic](https://www.tnd.dev/about/community/) Slack chat. (Please follow the above source links for additional details.) They're unfortunately no longer in the Slack archive due to history limits, so those screenshots which I took at the time may very well be the only proof of this information. If they sound shocking to you, they should!

But let me back up a moment. I _adored_ Jekyll. I loved it ever since I first discovered it—and the brave new world of static site generators—in 2016. As a refugee from the wild reaches of PHP & WordPress, I pivoted my own web studio, Whitefusion, to build Jekyll (and Rails) solutions for clients. I watched firsthand the rise of Netlify and the Jamstack. **I cheered Jekyll on from the bleachers** and wanted nothing but the best of success for the project…until it became clear to me in early 2020 that there were serious concerns to be had about the future viability of Jekyll. [Those concerns led me to fork Jekyll and create Bridgetown.](/news/time-to-visit-bridgetown/)

So everything I'm about to tell you comes from a place of love, not gamesmanship.

Back to the topic at hand…immediately after Frank posted the above comments, I attempted—repeatedly—to reach out to him in order for us personally to issue **a joint public statement** as to the nature of Jekyll's frozen status (and the implication that Bridgetown seemingly had become heir apparent to Jekyll), but to no avail. I can only speculate why he would feel free to communicate with me in The New Dynamic's Slack about Jekyll's frozen status—and wish me luck in building Bridgetown (!)—yet refrain from making any public statement to that effect.

I considered publishing my own unilateral statement concerning the matter, but in the end decided to respect Frank's desire to communicate only through the Slack chat and not work with me on a public statement. Since that time however, Frank has sadly and tragically passed away. ([Here's a wonderful obituary](https://tina.io/blog/our-friend-frank-taillandier/) by Scott Gallant, CEO of Forestry/TinaCloud.)

Normally the passing of the lead/release maintainer of a major GitHub project with over 43,300 stars (which also happens to be the progenitor of the modern Jamstack movement) would be a topic of conversation. But with no mention of this news and how it affects the Jekyll project on Jekyll's website, GitHub repo, or community forum as of September 13, 2021 (**9/14 UPDATE**: [a post written by Ashwin Maroli was published on Jekyll's website](http://jekyllrb.com/news/2021/09/14/goodbye-dear-frank/))—and with seemingly no involvement from GitHub directly (more on that shortly)—we can only surmise that the flow of public communication for the project truly has ceased.

Therefore, it's now the time where _I feel obligated_ to make a public appeal. In my honest assessment:

**There is no clear path forward for Jekyll as a viable and reliable open source technology.**

In recent years, the only other active core team member besides Frank—Ashwin Maroli—_was inexplicably absent for most of 2021_. As you can see in Frank's comments back in May, he believed Ashwin had simply stepped down for good. Mere weeks ago, however, Ashwin suddenly emerged once again in commits/comments on Jekyll's repo with no public mention of why, or what his next plans are.

**This doesn't inspire confidence in the future of Jekyll.**

I hope for the sake of everyone who relies on Jekyll for their businesses and organizations that Ashwin _has_ decided to remain and pay attention to Jekyll again, but I can tell you right now this is not how you establish and maintain trust in the open source community. Open source in 2021 looks like:

* Engagement on Twitter
* Official Discord chat room
* Public roadmap
* Predictable release cycles
* Welcoming community involvement in shaping new features and tackling technical debt
* Cultivating working relationships with wider ecosystems (in this case Ruby, Jamstack, etc.)

Lack of any one of these points isn't the end of the world, but at the present moment, _Jekyll lacks ALL of them._ That's a real problem.

Is Jekyll truly dead, as Frank surmised in his May 2021 comments? It all depends on how you look at it. But any honest assessment of the situation must acknowledge that Jekyll's future is in grave peril.

## Bridgetown's Road to 1.0 and the Future of Ruby Static Site Generators

Let's look at some positive developments that will provide a path forward for Jekyll users.

As lead maintainer for Bridgetown, I recently posted [a brand new roadmap for reaching v1.0 and beyond](https://www.bridgetownrb.com/future/roadmap-to-1.0/), along with our upcoming fundraising efforts to meet and exceed those goals. What I forgot to reiterate is _how important it is to me personally_ that we provide **clear guidelines and documentation** for Jekyll users who wish to upgrade to Bridgetown.

While Bridgetown has diverged somewhat from Jekyll in terms of architecture and is not source compatible (for example plugins and themes), it nevertheless remains "inspired by" Jekyll and can offer a compelling answer for nearly all of the features and configuration options Jekyll users know and love—all while adding a dizzying array of new features Jekyll has never and will likely never provide. I have yet to hear feedback from a former Jekyll user who didn't immediately fall in love with Bridgetown.

But if for some reason Bridgetown simply isn't to your liking, what's the alternative? You could try out another Ruby static site generator with a long and impressive pedigree, [Middleman](https://middlemanapp.com). There's also [Nanoc](https://nanoc.app).

Besides those, the most obvious choice (some might say) would be to switch to [Eleventy](https://www.11ty.dev), which is very popular and offers a fairly Jekyll-like experience but for JavaScript users in the NPM ecosystem.

I certainly have nothing against any of those projects and many more in the world of SSGs from Hugo to Pelican, but **I'm a Rubyist through and through**. I want **Jekyll** damnit! (Only _WAY_ better. 😅) That's why I started Bridgetown in the first place and why it's been making waves over the past 16 months. (See [here](https://www.therubyonrailspodcast.com/374), and [here](https://www.youtube.com/watch?v=btOuSOZd-6c), and [here](https://drunkenux.com/podcast/dux65/), and [here](https://remoteruby.transistor.fm/78), and…)

So let's stop beating around the bush. Despite the sad news regarding Jekyll, **the future for Ruby on the Jamstack remains bright indeed**, and we're here to lead the way. We'll be sharing the details on our first major fundraising effort along with a line-by-line project plan later this month. In the meantime, please [follow us on Twitter](https://twitter.com/bridgetownrb) and [join our Discord](https://discord.gg/4E6hktQGz4) so you won’t miss a thing.

----

• Some of you may be wondering _wait, I thought Jekyll was created by GitHub and powers GitHub Pages? Doesn't GitHub work on Jekyll?!_ The answer is…complicated. While Jekyll was indeed initially created by Tom Preston-Werner, the founder of GitHub, it has stood apart as a separately-maintained project for quite some time now. Matt Rogers, listed as one of three core team members, has no active code-level involvement other than an occasional PR review, and previous lead maintainer Parker Moore stepped down in 2018. Most damning however, is that GitHub Pages is still running on the Jekyll 3.x branch and _never upgraded_ to Jekyll 4! Yes, that's right: any meaningful improvements Jekyll has made in 4.0 and beyond are not available in GitHub Pages—unless you precompile your site using a GitHub Action. But if you do that, you can theoretically use any SSG—including Bridgetown! I suspect therein lies the actual future of the GitHub Pages produce…it's likely to evolve into a generic hosting tool and Jekyll will merely be one option among many. So no, from everything I can tell, GitHub won't suddenly be stepping in to "save" Jekyll. That ship, my friends, has sailed. As Rubyists and web developers, we must plan our next moves based on how things truly are, not on how we wish them to be. Once Jekyll sparked joy, now we must thank it, let it go, and press onward to a better future.

---
title: RIP Jekyll (Where the Jamstack First Began)
subtitle: "We are here to bear witness to the untimely demise of Jekyll, a once proud Ruby open source project and #1 static site generator in the world."
author: jared
category: future
---

{:style="text-align:center"}
"I can tell you there's no secret plan to revive Jekyll from the dead." ([source](/images/Screen Shot 2021-05-14 at 11.13.31 AM.png))  
"Jekyll is in frozen mode and permanent hiatus. RIP Jekyll 2009-2018." ([source](/images/Screen Shot 2021-05-14 at 11.11.01 AM.png))  
"Good luck to Jared White to build a modern SSG for the Ruby community."  

{:style="text-align:center"}
—_Frank Taillandier, (late) release maintainer of Jekyll (known as DirtyF on GitHub)_

{:style="margin-top: 2em"}
Those were comments Frank Taillandier posted in May 2021 in [The New Dynamic](https://www.tnd.dev/about/community/) Slack chat. (Please follow the above source links for greater detail.) The comments are unfortunately no longer in the Slack archive due to history limits, so those screenshots I took at the time may very well be the only proof of this information. If they sound shocking to you, they should!

Let me back up a moment. I _adored_ Jekyll, ever since I first discovered it in 2016. I pivoted my own web studio, Whitefusion, to build Jekyll (and Rails) solutions for clients. I watched the rise of Netlify and the Jamstack. **I cheered Jekyll on from the bleachers** and wanted nothing but the best of success for the project—until it became clear to me in early 2020 that there were serious concerns to be had about the future viability of Jekyll. [Those concerns led me to fork Jekyll and create Bridgetown.](/news/time-to-visit-bridgetown/)

But back to the topic at hand. Immediately after Frank posted those comments above, I tried repeatedly to reach out to him in order for us personally to issue a **joint public statement** as to the nature of Jekyll's frozen status (and the fact that Bridgetown seemingly had become heir apparent to Jekyll), but to no avail.

I considered making a unilateral statement about the matter, but decided to respect Frank's desire to communicate only through the Slack chat and not work with me on a public statement. Since that time, Frank has sadly and tragically passed away. ([Here's a wonderful obituary](https://tina.io/blog/our-friend-frank-taillandier/) by Scott Gallant, CEO of Forestry/TinaCloud.)

With no mention of this news and how it affects the Jekyll project on Jekyll's website, GitHub repo, or community forum (as of September 12, 2021)—and with seemingly no involvement from GitHub directly\*—I feel obligated to make this public appeal. In my honest assessment:

**There is no clear path forward for Jekyll as a viable and reliable open source technology.**

The only other core team member of several years, Ashwin Maroli, _was absent for most of 2021_—as you can see in Frank's comments back in May, he believed Ashwin had stepped down for good. Mere weeks ago, however, Ashwin suddenly appeared again in commits/comments on Jekyll's repo with no public mention of why, or what his next plans are.

**This doesn't inspire confidence in the future of Jekyll.**

I hope for the sake of everyone who relies on Jekyll for their businesses and organizations that Ashwin _has_ decided to pay attention to Jekyll again, but I can tell you right now this is not how you establish and maintain trust in the open source community.

### Bridgetown's Road to 1.0 and the Future of Ruby Static Site Generators

I recently posted [our brand new roadmap for reaching Bridgetown 1.0 and beyond](https://www.bridgetownrb.com/future/roadmap-to-1.0/), along with our upcoming fundraising efforts to meet and exceed those goals. What I forgot to reiterate is how important it is to me personally that we provide **clear guidelines and documentation** for Jekyll users who wish to upgrade to Bridgetown.

While Bridgetown has diverged somewhat from Jekyll in terms of architecture and is not source compatible (regarding plugins and themes), it nevertheless remains "inspired by" Jekyll and can offer a path forward for nearly all of the features and configuration options Jekyll users know and love—all while adding a dizzing array of new features Jekyll has never and will likely never provide.

If for some reason Bridgetown simply isn't to your liking, what's the alternative? You could try out another Ruby static site generator with a long and impressive pedigreee, [Middleman](https://middlemanapp.com). There's also [Nanoc](https://nanoc.app).

Otherwise, the most obvious choice (some might say) would be to switch to [Eleventy](https://www.11ty.dev), which offers a fairly Jekyll-like experience but for JavaScript users in the NPM ecosystem.

I have nothing against any of those projects and many more in the world of SSGs from Hugo to Pelican, but **I'm a Rubyist through and through** and I want **Jekyll** damnit—only _WAY_ better. 😅 That's why I started Bridgetown in the first place and why it's been making waves over the past 16 months.

So let's stop beating around the bush. Yes it's sad indeed to witness the demise of Jekyll, but **the future for Ruby on the Jamstack remains bright**, and we're here to lead the way. We'll share our detailed development strategy (aka line-by-line project plan) for the first fundraising effort later this month as well as the ability to contribute through one-time GitHub sponsorship packages, Stripe, or PayPal. In the meantime, please [follow us on Twitter](https://twitter.com/bridgetownrb) and [join the Discord](https://discord.gg/4E6hktQGz4) so you won’t miss a thing—and if you _really_ cannot wait, you can always [become a regular monthly sponsor of Bridgetown today](https://github.com/sponsors/jaredcwhite).

----

\* Some of you may be wondering _wait, I thought Jekyll was created by GitHub and powers GitHub Pages! Doesn't GitHub work on Jekyll?!_ The answer is…complicated. While Jekyll was indeed initially created by Tom Preson-Werner, the founder of GitHub, it's stood apart as a separately-maintained project for quite some time now. Mattr, listed as one of three core team members, has no active code-level involvement, and previous lead maintainer Parker Moore stepped down in 2019. Most damning however, is that GitHub Pages is still running on the Jekyll 3.x branch and _never upgraded_ to Jekyll 4! Yes, that's right: any meaningful improvements Jekyll has made in 4.0 and beyond are not available in GitHub Pages—unless you pre-compile your site using a GitHub Action. But if you do that, you can theoretically use any SSG—including Bridgetown! I suspect therein lies the actual future of GitHub Pages…it's likely to evolve into a generic hosting tool and Jekyll will merely be one option among many. So no, from everything I can tell, GitHub won't suddenly be stepping in to "save" Jekyll. That ship, my friends, has sailed. As Rubyists and web developers, we must plan our next moves based on how things truly are, not how we wish them to be. Once Jekyll sparked joy, now me must thank it, let it go, and press onward to a better future.
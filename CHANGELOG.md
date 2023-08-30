# Changelog

All notable changes to Bridgetown will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## Unreleased

## [1.3.1] - 2023-08-29

- Fix bug with prototype page pagination not working for paginate [#804](https://github.com/bridgetownrb/bridgetown/pull/804) ([jaredcwhite](https://github.com/jaredcwhite))
- Upgrade Cucumber to v8.0 [#800](https://github.com/bridgetownrb/bridgetown/pull/800) ([michaelherold](https://github.com/michaelherold))
- Fix `link_to` when passed block [#791](https://github.com/bridgetownrb/bridgetown/pull/791) ([jclusso](https://github.com/jclusso)) …thanks also to [fabionl](https://github.com/fabionl) for looking at this issue
- Add configurable inflector with examples for `ActiveSupport::Inflector` [#796](https://github.com/bridgetownrb/bridgetown/pull/796) ([jclusso](https://github.com/jclusso))
- esbuild & webpack version bumps [#802](https://github.com/bridgetownrb/bridgetown/pull/802) ([jaredcwhite](https://github.com/jaredcwhite))
- Add `date` task for generating a front matter friendly date ([jaredcwhite](https://github.com/jaredcwhite))
- Eager load to make DEFAULTS deterministic [#776](https://github.com/bridgetownrb/bridgetown/pull/776) ([michaelherold](https://github.com/michaelherold))
- Feature improvements to i18n localize [#783](https://github.com/bridgetownrb/bridgetown/pull/783) ([akarzim](https://github.com/michaelherold))
- Lock Rubocop to latest version that passes [#779](https://github.com/bridgetownrb/bridgetown/pull/779) ([michaelherold](https://github.com/michaelherold))
- Upgraded docs website to latest Ruby2JS and esbuild
- Thanks to @jclusso and @mtomov for improvements to documentation

## [1.3.0] - 2023-06-18

- esbuild and bundled configurations fixes

## [1.3.0.beta3] - 2023-06-18

- Lit configuration bug fixes based on QA

## [1.3.0.beta2] - 2023-06-18

- Declarative Shadow DOM integration [#763](https://github.com/bridgetownrb/bridgetown/pull/763) ([jaredcwhite](https://github.com/jaredcwhite))
- Retool esbuild configuration and add "Islands Architecture" [#765](https://github.com/bridgetownrb/bridgetown/pull/765) ([jaredcwhite](https://github.com/jaredcwhite))
- Add I18n localization shortcut "l" alongside "t" [#759](https://github.com/bridgetownrb/bridgetown/pull/759) ([goulvench](https://github.com/goulvench))
- Update to esbuild 0.17 [#762](https://github.com/bridgetownrb/bridgetown/pull/762) ([jaredcwhite](https://github.com/jaredcwhite))
- docs: update gitlab pages deploy configuration [#767](https://github.com/bridgetownrb/bridgetown/pull/767) ([akarzim](https://github.com/akarzim))
- docs: GitLab Pages serving compressed assets [#768](https://github.com/bridgetownrb/bridgetown/pull/768) ([akarzim](https://github.com/akarzim))
- docs: remove trailing comma in configuration options [#766](https://github.com/bridgetownrb/bridgetown/pull/766) ([akarzim](https://github.com/akarzim))

## [1.3.0.beta1] - 2023-05-01

- Fix missing word in `resources.md`
- Add support for Nokolexbor & Puma 6.x [#752](https://github.com/bridgetownrb/bridgetown/pull/752) ([jaredcwhite](https://github.com/jaredcwhite))
- Display build error on the page in a dialog in dev [#747](https://github.com/bridgetownrb/bridgetown/pull/747) ([jaredcwhite](https://github.com/jaredcwhite))
- Remove deprecated serve command and WEBrick [#750](https://github.com/bridgetownrb/bridgetown/pull/750) ([jaredcwhite](https://github.com/jaredcwhite))
- Fix locales warning bug [#748](https://github.com/bridgetownrb/bridgetown/pull/748) ([sandstrom](https://github.com/sandstrom))
- Fix hanging tmp dir when running test suite ([jaredcwhite](https://github.com/jaredcwhite))
- Relocate all Bridgetown Roda logic to new bridgetown_server plugin [#737](https://github.com/bridgetownrb/bridgetown/pull/737) ([jaredcwhite](https://github.com/jaredcwhite))
- Fix passing headers and add passing parameters to HTTP DSL [#722](https://github.com/bridgetownrb/bridgetown/pull/722) ([michaelherold](https://github.com/michaelherold))
- Fix: ensure hooks defined in initializers config are marked `reloadable: false` ([jaredcwhite](https://github.com/jaredcwhite))
- Fix purgecss plugin crashing when using scss [#733](https://github.com/bridgetownrb/bridgetown/pull/733) ([goulvench](https://github.com/goulvench))
- Upgrade to [Faraday v2](https://github.com/lostisland/faraday/blob/main/UPGRADING.md) [#721](https://github.com/bridgetownrb/bridgetown/pull/721) ([michaelherold](https://github.com/michaelherold)) & [#713](https://github.com/bridgetownrb/bridgetown/pull/713) ([alison-acuna](https://github.com/alison-acuna))
  - Removed dependency on `faraday_middleware`, which was deprecated, and not ported to Faraday v2.
  - Added dependency on `faraday-follow_redirects` to replace functionality from ^ that was lost
- Thanks to @dcr8898, @fbuys, @beeburrt, @neilvanbeinum, and @pboling for documentation improvements

## [1.2.0] - 2022-01-25

- Remove terminal-table dependency
  **Possible breaking change** — if you rely on Liquid template profiling to debug your site, you'll need to add the `terminal-table` gem dependency yourself
- Add method to reset config for test suites [#702](https://github.com/bridgetownrb/bridgetown/pull/702) ([jaredcwhite](https://github.com/jaredcwhite))
- Fix: Set timezone from initializer Ruby DSL [#703](https://github.com/bridgetownrb/bridgetown/pull/703) ([ayushn21](https://github.com/ayushn21))
- Fix a minor typo in the plugins command [#701](https://github.com/bridgetownrb/bridgetown/pull/701) ([ayushn21](https://github.com/ayushn21))
- Fix: load `initializers.rb` instead of require for working tests [#700](https://github.com/bridgetownrb/bridgetown/pull/700) ([jaredcwhite](https://github.com/jaredcwhite))
- Docs: Add details for importing Shoelace [#698](https://github.com/bridgetownrb/bridgetown/pull/698) ([ikass](https://github.com/ikass))

## [1.2.0.beta5] - 2022-01-02

- Add some DX improvements to StaticFile [#677](https://github.com/bridgetownrb/bridgetown/pull/677) ([jaredcwhite](https://github.com/jaredcwhite))
- Restore localhost URL in development when using initializers config [#686](https://github.com/bridgetownrb/bridgetown/pull/686) ([jaredcwhite](https://github.com/jaredcwhite))
- Note View Component oddities [#687](https://github.com/bridgetownrb/bridgetown/pull/687) ([joemasilotti](https://github.com/joemasilotti))
- Fix: dynamic route sorting [#690](https://github.com/bridgetownrb/bridgetown/pull/690) ([jaredcwhite](https://github.com/jaredcwhite))
- Fix: Enture `resource.data.locale` consistently return symbols [#682](https://github.com/bridgetownrb/bridgetown/pull/682) ([vvveebs](https://github.com/vvveebs))
- Filter `Bridgetown::Localizable#all_locales` under the source's parent directory [#671](https://github.com/bridgetownrb/bridgetown/pull/671) ([vvveebs](https://github.com/vvveebs))
- Website: Fix the readability of namespaces in dark mode [#674](https://github.com/bridgetownrb/bridgetown/pull/674) ([michaelherold](https://github.com/michaelherold))
- Add support for alternative gemfile `gems.rb` to core [#658](https://github.com/bridgetownrb/bridgetown/pull/658) ([svoop](https://github.com/svoop))

## [1.2.0.beta4] - 2022-12-07

- Provide an option for the file watcher to watch additional paths [#668](https://github.com/bridgetownrb/bridgetown/pull/668) ([jaredcwhite](https://github.com/jaredcwhite))
- Localize file-based dynamic routes [#654](https://github.com/bridgetownrb/bridgetown/pull/654) ([tommasongr](https://github.com/tommasongr))
- Website: Dark mode [#620](https://github.com/bridgetownrb/bridgetown/pull/620) ([vvveebs](https://github.com/vvveebs))
- Docs: Fix typo in collections.md [#664](https://github.com/bridgetownrb/bridgetown/pull/664) ([fbuys](https://github.com/fbuys))
- Update GitHub Pages configuration to use new method of deploying websites. [#657](https://github.com/bridgetownrb/bridgetown/pull/657) ([tombruijn](https://github.com/tombruijn))
- Bump up esbuild version in new template and on the BT site [#646](https://github.com/bridgetownrb/bridgetown/pull/646) ([jaredcwhite](https://github.com/jaredcwhite))
- Fix: ensure Rake tasks can be run directly, and no crashes when Rake isn't available [#656](https://github.com/bridgetownrb/bridgetown/pull/656) ([jaredcwhite](https://github.com/jaredcwhite))
- Parse using JSON.parse for more resilient parsing [#662](https://github.com/bridgetownrb/bridgetown/pull/662) ([rickychilcott](https://github.com/rickychilcott))
- Resolve Rubocop offenses [#644](https://github.com/bridgetownrb/bridgetown/pull/644) ([vvveebs](https://github.com/vvveebs))
- Docs: Fix link to Liquid Template Engine [#659](https://github.com/bridgetownrb/bridgetown/pull/659) ([KorbsStudio](https://github.com/KorbsStudio))
- Specify locales in "multi locale" mode [#651](https://github.com/bridgetownrb/bridgetown/pull/651) ([rickychilcott](https://github.com/rickychilcott))
- Change from master to main in additional places throughout the code [#648](https://github.com/bridgetownrb/bridgetown/pull/648) ([Dynnammo](https://github.com/Dynnammo))
- Fix Lint/ConstantDefinitionInBlock and Style/StructInheritance [#640](https://github.com/bridgetownrb/bridgetown/pull/640) ([lxxxvi](https://github.com/lxxxvi))
- Docs: Correct Typo in _docs/template-engines.md [#649](https://github.com/bridgetownrb/bridgetown/pull/649) ([jacobdaddario](https://github.com/jacobdaddario))
- Fix: update broken initializers documentation link [#652](https://github.com/bridgetownrb/bridgetown/pull/652) ([andrewmcodes](https://github.com/andrewmcodes))
- Extend url_for helper to accept other link types [#633](https://github.com/bridgetownrb/bridgetown/pull/633) ([alexanderadam](https://github.com/alexanderadam))
- Extend link_to helper to accept blocks [#632](https://github.com/bridgetownrb/bridgetown/pull/632) ([alexanderadam](https://github.com/alexanderadam))
- Docs: Fix typo in confirmation prompt [#645](https://github.com/bridgetownrb/bridgetown/pull/645) ([brandoncc](https://github.com/brandoncc))
- Docs: typo: mergable => mergeable [#635](https://github.com/bridgetownrb/bridgetown/pull/635) ([alexanderadam](https://github.com/alexanderadam))
- Docs: fix typo: delimeters => delimiters [#634](https://github.com/bridgetownrb/bridgetown/pull/634) ([alexanderadam](https://github.com/alexanderadam))
- Add ability to specify locales in "multi locale" mode [#651](https://github.com/bridgetownrb/bridgetown/pull/651) ([rickychilcott](https://github.com/rickychilcott))

## [1.2.0.beta3] - 2022-10-09

- Updates to Lit and Tailwind configurations
- Add new automation actions for v1.2 configurations
- Fix issues around Roda processing of form submissions

## [1.2.0.beta2] - 2022-10-07

- Fix bug with builder registration in config DSL

## [1.2.0.beta1] "Bonny Slope" - 2022-10-02

Don't let yourself get distracted by the moonshine!
https://cedarmillnews.com/legacy/archive/706/bonny_slope_bootleggers.html

### General

- Add gemspec metadata for all gems (#619)

## Added

- Major refactor to add new configuration & initializer DSLs [#618](https://github.com/bridgetownrb/bridgetown/pull/618) ([jaredcwhite](https://github.com/jaredcwhite))
  - All-new Ruby-based config file format
  - New Dotenv support
  - Refactor to setup Bundler without automatic requires
  - Relocate Roda plugins to their own files and use new init functionality
  - Add permalink placeholder to Builder DSL
  - Improve helper scope for methods, add resource extension to Builder DSL
  - Deprecate TOML, `_config`, and `.yaml` files for configurations (`.yml` preferred)
- Slot content feature for templates and components [#629](https://github.com/bridgetownrb/bridgetown/pull/629) ([jaredcwhite](https://github.com/jaredcwhite))
- Allow templates to use `data` directly instead of `resource.data` or even `site.data` [#622](https://github.com/bridgetownrb/bridgetown/pull/622) ([jaredcwhite](https://github.com/jaredcwhite) and [johlym](https://github.com/johlym))
- Add Dockerfile to deployment options [#626](https://github.com/bridgetownrb/bridgetown/pull/626) ([stephendolan](https://github.com/stephendolan))
- Add hash attributes functionality to view tag helpers [#589](https://github.com/bridgetownrb/bridgetown/pull/589) ([DRBragg](https://github.com/DRBragg))
- Provide esbuild config typing via JSDoc [#604](https://github.com/bridgetownrb/bridgetown/pull/604) ([jaredcwhite](https://github.com/jaredcwhite))

## Changed

- Update postcss-load-config to 4.x and address synchronization issues [#596](https://github.com/bridgetownrb/bridgetown/pull/596) ([stefanvermaas](https://github.com/stefanvermaas))
  **Possible breaking change** — see: https://github.com/bridgetownrb/bridgetown/pull/596#issuecomment-1236028272
- Tailwind automation has been relocated to a separate repository — see: https://github.com/bridgetownrb/tailwindcss-automation
- Include subdirectories of `src/_locales` in I18n loader [#606](https://github.com/bridgetownrb/bridgetown/pull/606) ([lux-shaun](https://github.com/lux-shaun))

## Fixed

- Update SSR tests to work with Rack 3 [#627](https://github.com/bridgetownrb/bridgetown/pull/627) ([vvveebs](https://github.com/vvveebs))
- Use regional fallbacks from i18n [#607](https://github.com/bridgetownrb/bridgetown/pull/607) ([lux-shaun](https://github.com/lux-shaun))
- esbuild entrypoint selection for index.css [#621](https://github.com/bridgetownrb/bridgetown/pull/627) ([zealot128](https://github.com/zealot128))
- Silence kwargs warning in ruby 2.7 [#615](https://github.com/bridgetownrb/bridgetown/pull/615) ([sandstrom](https://github.com/sandstrom))
- New GitHub Pages configurations will deploy a production build [#610](https://github.com/bridgetownrb/bridgetown/pull/610) ([vvveebs](https://github.com/vvveebs))

## [1.1.0] — 2022-07-18

- Add better error message for YAML parse error around Symbols
- Remove unnecessary `excerpt_separator` configuration default
- New docs: a guide how to migrate from Jekyll [#594](https://github.com/bridgetownrb/bridgetown/pull/594) ([jaredcwhite](https://github.com/jaredcwhite))
- Improved default Liquid layout
- Fix PurgeCSS configuration so it works with esbuild

## [1.1.0.beta3] — 2022-06-28

- Provide URL helpers to Roda [#583](https://github.com/bridgetownrb/bridgetown/pull/583) ([jaredcwhite](https://github.com/jaredcwhite))
- Support kwargs-only method calls for `partial` [#582](https://github.com/bridgetownrb/bridgetown/pull/582) ([jaredcwhite](https://github.com/jaredcwhite))
- Switch from `rack-indifferent` to Roda's `indifferent_params` plugin [#586](https://github.com/bridgetownrb/bridgetown/pull/586) ([jaredcwhite](https://github.com/jaredcwhite)) with thanks to @jeremyevans
- Thanks to [work-leonid](https://github.com/andrewmcodes) for docs improvements
- Fix: apply Inspectors to Generated Pages as well
  - **Breaking change from beta2**
- Update Gemfile template with nokogiri commented out (helps with the Inspectors API) [#574](https://github.com/bridgetownrb/bridgetown/pull/574) ([andrewmcodes](https://github.com/andrewmcodes))
- Fix migrate-from-webpack process [#573](https://github.com/bridgetownrb/bridgetown/pull/573) ([katafrakt](https://github.com/katafrakt))
- Ensure gem-based Builders are part of priority sorting [#567](https://github.com/bridgetownrb/bridgetown/pull/567) ([jaredcwhite](https://github.com/jaredcwhite))
- Add `fill: "forwards"` to improve Turbo transition states

## [1.1.0.beta2] — 2022-06-01

- Update Webpack 5 default config to switch to native asset loaders (no more `file-loader` needed)

## [1.1.0.beta1] — 2022-06-01

- New bundled configurations: Lit, Shoelace, Ruby2JS, Open Props [#553](https://github.com/bridgetownrb/bridgetown/pull/553) ([jaredcwhite](https://github.com/jaredcwhite))
  - NOTE: "frontend component files" (aka `.js`/`.css` files within the `src/_components` folder) will now be ignored by the build process watcher, thus allowing the frontend bundling refresh to trigger a dev reload
- Improve Roda error handling and update static error pages [#565](https://github.com/bridgetownrb/bridgetown/pull/565) ([jaredcwhite](https://github.com/jaredcwhite))
- Always make sure `:en` is at the end of the I18n fallback chain
- Support `.rb` and `.json` for translation files
- Support front matter defaults for multi locale
- Update `in_locale` to support filtering resources
- Add `t` Liquid filter, allow I18n fallbacks
- Allow `.multi` suffix on files names for multi locales
- feat: add rb files to the Tailwind content glob [#564](https://github.com/bridgetownrb/bridgetown/pull/564) ([andrewmcodes](https://github.com/andrewmcodes))
- Fix default custom collection permalink so it includes the locale prefix
- Add link to configuration options documentation in the default `bridgetown.config.yml` [#563](https://github.com/bridgetownrb/bridgetown/pull/563) ([andrewmcodes](https://github.com/andrewmcodes))
- Simplify the Roda boot process, add more route tests [#562](https://github.com/bridgetownrb/bridgetown/pull/562) ([jaredcwhite](https://github.com/jaredcwhite))
- Add Sass support for esbuild, update frontend dependency versions [#542](https://github.com/bridgetownrb/bridgetown/pull/542) ([jaredcwhite](https://github.com/jaredcwhite))
  - Add ability to configure file filter for PostCSS plugin
  - Fix PostCSS esbuild watch bug & remove easy-import
- Update Tailwind config so jit-refresh.css is git ignored [#559](https://github.com/bridgetownrb/bridgetown/pull/559) ([jaredcwhite](https://github.com/jaredcwhite))
- Ensure future-dated resources import only when expected [#558](https://github.com/bridgetownrb/bridgetown/pull/558) ([jaredcwhite](https://github.com/jaredcwhite))
- Inherit generator priority from builder
  - **BREAKING CHANGE:** (maybe) The exact order multiple generators will run in may be subtly different than before. Use Builder priorities to resolve
- Add HTML & XML Inspectors API using Nokogiri [#546](https://github.com/bridgetownrb/bridgetown/pull/546) ([jaredcwhite](https://github.com/jaredcwhite)) & ([andrewmcodes](https://github.com/andrewmcodes))
- Add default locale prefixing config option, `in_locale` template filter/helper [#540](https://github.com/bridgetownrb/bridgetown/pull/540) ([jaredcwhite](https://github.com/jaredcwhite))
- Add Markdown support to convert `==` / `::` to `<mark>` [#551](https://github.com/bridgetownrb/bridgetown/pull/551) ([jaredcwhite](https://github.com/jaredcwhite))
- Apply default theme for syntax highlighting [#516](https://github.com/bridgetownrb/bridgetown/pull/516) ([jaredlt](https://github.com/jaredlt))
- Add site `server_shutdown` hook via Puma
- Allow route classes to be prioritized to adjust run order [#538](https://github.com/bridgetownrb/bridgetown/pull/538) ([jaredcwhite](https://github.com/jaredcwhite))
- Fix: ensure capturing helpers use dedicated component context
- Fix typo in "Core Principles": focsued → focused [#541](https://github.com/bridgetownrb/bridgetown/pull/541) ([das-g](https://github.com/das-g))
- Allow finding and linking to alternate locale pages [#522](https://github.com/bridgetownrb/bridgetown/pull/522) ([jaredcwhite](https://github.com/jaredcwhite))
- Issue warning when a Rails-style extension is used (like .html.erb) [#523](https://github.com/bridgetownrb/bridgetown/pull/523) ([jaredcwhite](https://github.com/jaredcwhite))
- Fix Roda serving bug when index.html is missing
- Re-run SSR setup block on live reload
- Trigger pre/post-read hooks on SSR reload
  - **BREAKING CHANGE:** (maybe) If you had long-running code in a plugin `build` method or a hook, this might surprise you when you live reload in dev using dynamic routes. Use `site.ssr?` if you want to bypass code in SSR mode.
- Fix bug where sidecar aux process wasn't requiring bundler groups [#532](https://github.com/bridgetownrb/bridgetown/pull/532) ([jaredcwhite](https://github.com/jaredcwhite))

## [1.0.0] (stable release) — 2022-03-07

- Add bundled configuration for GH pages [#503](https://github.com/bridgetownrb/bridgetown/pull/503) ([ayushn21](https://github.com/ayushn21))
- Fix `base_path` issues with Roda and site templates [#510](https://github.com/bridgetownrb/bridgetown/pull/510) ([jaredcwhite](https://github.com/jaredcwhite))
- Many documentation tweaks
- Plus _everything_ since v0.21!

## 1.0.0.beta3 — 2022-02-18

- Project repo Gemfile cleanup
- Remove the Renderer class by merging into GeneratedPage [#492](https://github.com/bridgetownrb/bridgetown/pull/492) ([jaredcwhite](https://github.com/jaredcwhite))
- Cleaner paginated page URL [#491](https://github.com/bridgetownrb/bridgetown/pull/491) ([jaredcwhite](https://github.com/jaredcwhite))
- Documentation updates by [fpsvogel](https://github.com/fpsvogel) and [subsevenx](https://github.com/subsevenx)

## 1.0.0.beta2 — 2022-01-26

- Partials rendering speedup by nearly 8x (!) [#489](https://github.com/bridgetownrb/bridgetown/pull/489) ([jaredcwhite](https://github.com/jaredcwhite))
- Map Stimulus controller filenames to identifiers as in the Stimulus docs [#486](https://github.com/bridgetownrb/bridgetown/pull/486) ([fpsvogel](https://github.com/fpsvogel))
- Fix for issue #482: don't load front matter defaults for data collection ([jaredcwhite](https://github.com/jaredcwhite))
- Add bundled configuration for Vercel [#483](https://github.com/bridgetownrb/bridgetown/pull/483) ([andrewmcodes](https://github.com/andrewmcodes))
- Descendants tracker fix for issue #484 ([jaredcwhite](https://github.com/jaredcwhite))

## 1.0.0.beta1 — 2022-01-13

### General

- Brand new [website](https://edge.bridgetownrb.com) and refreshed documentation. _Yowza!_ Special thanks to [@adrianvalenz](https://github.com/adrianvalenz) for contributing refreshed branding and content enhancements and to [Whitefusion](https://www.whitefusion.studio) for overall design & development of the new site.

### Added

- Native esbuild integration, default site template switched to use esbuild + postcss [#461](https://github.com/bridgetownrb/bridgetown/pull/461) ([jaredcwhite](https://github.com/jaredcwhite))
  - **BREAKING CHANGE:** you will need to run `bin/bridgetown webpack update` so the build process can find the relocated assets manifest file.
- New site template design along with ERB and Serbea support via CLI flags [#475](https://github.com/bridgetownrb/bridgetown/pull/461) ([jaredcwhite](https://github.com/jaredcwhite))

### Changed

- Refactor how Rake tasks are loaded or displayed ([jaredcwhite](https://github.com/jaredcwhite))
- Clean up listener and watcher, resolves #467 ([jaredcwhite](https://github.com/jaredcwhite))
- Update Stimulus and Turbo configurations to latest versions ([jaredcwhite](https://github.com/jaredcwhite))
- Permit Rails 7 versions of Active Support & Active Model ([jaredcwhite](https://github.com/jaredcwhite))
- Improve the display of build errors [#479](https://github.com/bridgetownrb/bridgetown/pull/479) ([jaredcwhite](https://github.com/jaredcwhite))
- Remove the Swup bundled configuration and enhance Turbo instead [#471](https://github.com/bridgetownrb/bridgetown/pull/471) ([jaredcwhite](https://github.com/jaredcwhite))

### Fixed

- Switch routes to path from absolute_path for Ruby 3.1 compatibility ([jaredcwhite](https://github.com/jaredcwhite))
- Fix origins autoload issue in #472 ([jaredcwhite](https://github.com/jaredcwhite))
- Add `.ruby-version` file to new sites ([jaredcwhite](https://github.com/jaredcwhite))

## 1.0.0.alpha11 - 2021-11-29

- Allow saving of models with repo origin [#452](https://github.com/bridgetownrb/bridgetown/pull/452) ([jaredcwhite](https://github.com/jaredcwhite))
- Normalize previous/next resource API between Ruby and Liquid [#466](https://github.com/bridgetownrb/bridgetown/pull/466) ([jaredcwhite](https://github.com/jaredcwhite))
- Docs: Add a nginx section in deployment [#447](https://github.com/bridgetownrb/bridgetown/pull/447) ([Eric-Guo](https://github.com/Eric-Guo))
- Switch to streaming/event source mechanism for live reload [#458](https://github.com/bridgetownrb/bridgetown/pull/458) ([jaredcwhite](https://github.com/jaredcwhite))
- Hooks refactor & cleaning up SSR reload hook [#457](https://github.com/bridgetownrb/bridgetown/pull/457) ([jaredcwhite](https://github.com/jaredcwhite))
- Add `BRIDGETOWN_ENV` to render config [#460](https://github.com/bridgetownrb/bridgetown/pull/460) ([ayushn21](https://github.com/ayushn21))
- Fix production ENV issue with Roda file-based routes
- Move `Collection#sort_resources!` to a public method

## 1.0.0.alpha10 - 2021-11-15

- Fix class duplication bug with reloads and `ActiveSupport::DescendantsTracker` [#450](https://github.com/bridgetownrb/bridgetown/pull/450) ([jaredcwhite](https://github.com/jaredcwhite))
- Remove extra space from plugins command output [#449](https://github.com/bridgetownrb/bridgetown/pull/449) ([jacobherrington](https://github.com/jacobherrington))

## 1.0.0.alpha9 - 2021-11-11

- Remove the Liquid Component gem dependency
- Add support for environment CLI flags (`-e production` or `--environment=production`)
- Integrate Serbea 1.0 into Bridgetown [#440](https://github.com/bridgetownrb/bridgetown/pull/440) ([jaredcwhite](https://github.com/jaredcwhite))
- Add new console commands via ConsoleMethods mixin [#439](https://github.com/bridgetownrb/bridgetown/pull/439) ([jaredcwhite](https://github.com/jaredcwhite)
- Support long version form in CLI (`--version`) [#445](https://github.com/bridgetownrb/bridgetown/pull/445) ([Eric-Guo](https://github.com/Eric-Guo))

### Documentation

- Skip the archived state in plugins. [#443](https://github.com/bridgetownrb/bridgetown/pull/443) ([Eric-Guo](https://github.com/Eric-Guo))
- Update ruby2js as required by webpack loader [#442](https://github.com/bridgetownrb/bridgetown/pull/442) ([Eric-Guo](https://github.com/Eric-Guo))

## 1.0.0.alpha8 - 2021-11-05

- Refactor builder DSL for Ruby 2.7 & 3.0 compatibility

## 1.0.0.alpha7 - 2021-11-05

- Update minimum Ruby requirement to 2.7
- Copy `bin/bridgetown` to `bin/bt` after binstubs generation
- Ensure Webpack error messages only display once
- Add bundled configuration for Cypress [#339](https://github.com/bridgetownrb/bridgetown/pull/339) ([ayushn21](https://github.com/ayushn21))
- Use Zeitwerk for autoload/eager load paths (including plugins) [#434](https://github.com/bridgetownrb/bridgetown/pull/434) ([jaredcwhite](https://github.com/jaredcwhite) & [ayushn21](https://github.com/ayushn21))
- Don't mutate bundler dependencies in place [#433](https://github.com/bridgetownrb/bridgetown/pull/433) ([deivid-rodriguez](https://github.com/deivid-rodriguez))
- Add bundled configuration for Render [#431](https://github.com/bridgetownrb/bridgetown/pull/431) ([ayushn21](https://github.com/ayushn21))

## 1.0.0.alpha6 - 2021-10-26

- Detect the presence of Puma a different way [#430](https://github.com/bridgetownrb/bridgetown/pull/430) ([jaredcwhite](https://github.com/jaredcwhite))
- Fix netlify config to use native deploy command [#429](https://github.com/bridgetownrb/bridgetown/pull/429) ([ayushn21](https://github.com/ayushn21))

## 1.0.0.alpha5 - 2021-10-22

- The deprecated `include` and `include_relative` tags have been removed.

## 1.0.0.alpha4 - 2021-10-18

- Refactor and cleanup of routing gem for better maintainability [#424](https://github.com/bridgetownrb/bridgetown/pull/424) ([jaredcwhite](https://github.com/jaredcwhite))
  - Also adds `bin/bridgetown secret` which functions much like the `bin/rails secret` to generate a long randomized hex token.

## 1.0.0.alpha3 - 2021-10-17

- Allow template engines to accept symbols via Ruby front matter [#396](https://github.com/bridgetownrb/bridgetown/pull/396) ([JuanVqz](https://github.com/JuanVqz))
- Add build callbacks to Builder plugins and allow arbitrary instantiation [#422](https://github.com/bridgetownrb/bridgetown/pull/422) ([jaredcwhite](https://github.com/jaredcwhite))

## 1.0.0.alpha2 - 2021-10-15

- Upgrade the codebase to Rubocop 1.22 and use config from `rubocop-bridgetown` gem

## 1.0.0.alpha1 - 2021-10-15

**NOTE:** this is still considered experimental and largely undocumented.
It's fine to use...just not recommended for production. =)

### General

- Strip out all of the legacy content engine [#415](https://github.com/bridgetownrb/bridgetown/pull/415) ([jaredcwhite](https://github.com/jaredcwhite))
  - Transition Page to GeneratedPage
  - Resource content from plugins now supported

- SSR & file-based dynamic routes in src/_routes [#383](https://github.com/bridgetownrb/bridgetown/pull/383) ([jaredcwhite](https://github.com/jaredcwhite))
  - includes adding Puma, Rack, Roda, and Rake!
  - the previous WEBrick-based dev server is deprecated
  - nearly all past Yarn commands are now available through `bin/bridgetown`

### Added

- `add_resource` DSL now available for builders [#419](https://github.com/bridgetownrb/bridgetown/pull/419) ([jaredcwhite](https://github.com/jaredcwhite))
- Improve locale routing based on filenames or special front matter [#414](https://github.com/bridgetownrb/bridgetown/pull/414) ([jaredcwhite](https://github.com/jaredcwhite))
- Enhance front matter DSL with nesting and lambda value eval [#398](https://github.com/bridgetownrb/bridgetown/pull/398) ([jaredcwhite](https://github.com/jaredcwhite))
- Add debug message when saving static files

### Fixed

- Improve resource engine compatibility in link tag and url_for helper [#389](https://github.com/bridgetownrb/bridgetown/pull/389) ([jaredcwhite](https://github.com/jaredcwhite))
- Prevent `.js` matches with any file like `foo.js.txt.bat.png` [#399](https://github.com/bridgetownrb/bridgetown/issues/399) ([nachoal](https://github.com/nachoal/))

### Changed

- Change single quotes in script folder [#406](https://github.com/bridgetownrb/bridgetown/pull/406) ([JuanVqz](https://github.com/JuanVqz))
- Return ordered results for belongs_to array [#390](https://github.com/bridgetownrb/bridgetown/pull/390) ([jaredcwhite](https://github.com/jaredcwhite))
- Bumped minimum recommended Node requirement to v12 and updated the docs for Homebrew installation on macOS.

### Removed

- Remove pry and use binding.irb in dev console script
- Remove incremental generation [#388](https://github.com/bridgetownrb/bridgetown/pull/388) ([jaredcwhite](https://github.com/jaredcwhite))

## 0.21.4 - 2021-09-10

### Fixed

- Allow symbols for use in pagination/prototype front matter [#386](https://github.com/bridgetownrb/bridgetown/pull/386) ([jaredcwhite](https://github.com/jaredcwhite))
- Ensure the data collection is read first [#373](https://github.com/bridgetownrb/bridgetown/pull/373) ([jaredcwhite](https://github.com/jaredcwhite))
- Strip out newlines in generated package.json and index.js [#369](https://github.com/bridgetownrb/bridgetown/pull/369) ([eclectic-coding](https://github.com/eclectic-coding))

### Changed

- Resolve postcss-focus-within to v4 [#366](https://github.com/bridgetownrb/bridgetown/pull/366) ([ayushn21](https://github.com/ayushn21))
- Performance refactor of the Webpack helper [#382](https://github.com/bridgetownrb/bridgetown/pull/382) ([jaredcwhite](https://github.com/jaredcwhite))
- Several documentation improvments thanks to JuanVqz and debashis-biswal

## 0.21.3 - 2021-08-06

### Fixed

- Resource: switch from default proc to preemptive defaults [#359](https://github.com/bridgetownrb/bridgetown/pull/359) ([jaredcwhite](https://github.com/jaredcwhite))
- Ensure there aren't double-slashes in pagination links ([jaredcwhite](https://github.com/jaredcwhite))
- Ensure summary content is html safe ([jaredcwhite](https://github.com/jaredcwhite))

## 0.21.2 - 2021-07-21

### Fixed

- Add missing comma in package.json which broken install #354

## 0.21.1 - 2021-07-19

### Added

- Resource extension API along with basic summary feature [#344](https://github.com/bridgetownrb/bridgetown/pull/344) ([jaredcwhite](https://github.com/jaredcwhite)) [Read the Docs](https://www.bridgetownrb.com/docs/resources#resource-extensions)

### Fixed

- Unintentional overwriting of data when using the Resource content engine [#343](https://github.com/bridgetownrb/bridgetown/pull/343) ([jaredcwhite](https://github.com/jaredcwhite))
- Bug where in Liquid the `next_resource` method would mistakenly return the previous resource

### Changed

- Configure sites in subfolders via base_path, not baseurl [#348](https://github.com/bridgetownrb/bridgetown/pull/348) ([jaredcwhite](https://github.com/jaredcwhite))
- Swap babel for ESBuild and upgrade to Webpack 5 [#334](https://github.com/bridgetownrb/bridgetown/pull/334) ([ayushn21](https://github.com/ayushn21))
- Change postcss.config.js stage from 3 to 2 [#349](https://github.com/bridgetownrb/bridgetown/pull/349) ([juhat](https://github.com/juhat)) [Read the Docs](https://www.bridgetownrb.com/docs/frontend-assets#postcss)
- Various improvements to the new Webpack config documentation

## 0.21.0 - 2021-06-01

Final release of 0.21.0! See below for full changelog.

### Fixed

- Configuration change to remove Webpack warning regarding Babel [#314](https://github.com/bridgetownrb/bridgetown/pull/314) ([eclectic-coding](https://github.com/eclectic-coding))

## 0.21.0.beta4 - 2021-05-30

### Added

- Memoization for caching templates in `Bridgetown::Component` [#326](https://github.com/bridgetownrb/bridgetown/pull/326) ([jaredcwhite](https://github.com/jaredcwhite))
- `layout` method in `Resource::Base` [#324](https://github.com/bridgetownrb/bridgetown/pull/324) ([jaredcwhite](https://github.com/jaredcwhite))
- Include Bridgetown version in Webpack defaults [#322](https://github.com/bridgetownrb/bridgetown/pull/322) ([ayushn21](https://github.com/ayushn21))
- Confirmation for overwriting postcss config in tailwindcss and bt-postcss bundled configurations [#317](https://github.com/bridgetownrb/bridgetown/pull/317) ([ayushn21](https://github.com/ayushn21))
- Create new config directory and move Webpack defaults into it [#316](https://github.com/bridgetownrb/bridgetown/pull/316) ([ayushn21](https://github.com/ayushn21))

### Changed

- Fix the Bridgetown logger and other test improvements [#328](https://github.com/bridgetownrb/bridgetown/pull/328) ([ayushn21](https://github.com/ayushn21))
  - **NOTE:** the `Configuration file` log message is now output with a `debug` log level instead of `info`. This means you will no longer see the config path in your terminal/logs unless you use the `--verbose` flag.

### Fixed

- Install required packages in Webpack enable postcss tool [#319](https://github.com/bridgetownrb/bridgetown/pull/319) ([ayushn21](https://github.com/ayushn21))
- Update Babel configuration to prevent overt warning [#314](https://github.com/bridgetownrb/bridgetown/pull/314) ([ayushn21](https://github.com/ayushn21))
- Resolve issue with zombie templates in Pagination/Prototype logic
- Locale files now reload when the site regenerates

## 0.21.0.beta3 - 2021-05-15

### Changed

- Switch to using a Keep a Changelog format.
- Switch `plugins new` command to use MiniTest from the sample plugin repo.
- Make configure command use Thor's apply method directly [#293](https://github.com/bridgetownrb/bridgetown/pull/293) ([ayushn21](https://github.com/ayushn21))

### Fixed

- Resources configured not to output to a destination are now transformed as expected.
- The `previous_resource` method now returns the proper resource.
- Fix warnings in plugin tests by checking if an ivar was defined [#296](https://github.com/bridgetownrb/bridgetown/pull/296) ([ayushn21](https://github.com/ayushn21))
- Ensure Netlify script is set to executable. [#302](https://github.com/bridgetownrb/bridgetown/pull/302) ([ayushn21](https://github.com/ayushn21))
- Consider the default branch from the git config when creating a new site or plugin. [#294](https://github.com/bridgetownrb/bridgetown/pull/294) ([ayushn21](https://github.com/ayushn21))

### Removed

- A bunch of global config accessors on site (like `lsi`, `keep_files`, etc.)
- Remove safe_yaml gem in favour of using Psych which is in the stdlib. [#303](https://github.com/bridgetownrb/bridgetown/pull/303) ([ayushn21](https://github.com/ayushn21))

## 0.21.0.beta2 - 2021-05-08

* Refactor old TODOs and deprecations
* Remove deprecated `sassify`/`scssify` filters, add html_safe to the `obfuscate_link` helper
* Fix dotfiles or multiple extension permalinks (for the resource content engine) [#292](https://github.com/bridgetownrb/bridgetown/pull/292) ([jaredcwhite](https://github.com/jaredcwhite))

## 0.21.0.beta1 - 2021-04-25

* End-to-end Ruby [front matter, templates](https://www.bridgetownrb.com/docs/resources#ruby-front-matter-and-all-ruby-templates), and [data files](https://www.bridgetownrb.com/docs/datafiles) ([jaredcwhite](https://github.com/jaredcwhite)) [#285](https://github.com/bridgetownrb/bridgetown/pull/285)
* New `Bridgetown::Component` class with a ViewComponent-inspired API [#268](https://github.com/bridgetownrb/bridgetown/pull/268) ([jaredcwhite](https://github.com/jaredcwhite)) [Read the Docs](https://www.bridgetownrb.com/docs/components/ruby)
  * **Breaking Change:** ERB now uses an output safety buffer to escape HTML in strings, same as in Rails. [Read the Docs](https://www.bridgetownrb.com/docs/erb-and-beyond#escaping-and-html-safety)
* Relations for resources (belongs_to, has_many, etc.) [#261](https://github.com/bridgetownrb/bridgetown/pull/261) ([jaredcwhite](https://github.com/jaredcwhite)) [Read the Docs](https://www.bridgetownrb.com/docs/resources#resource-relations)
* Migrate to dart-sass since node-sass is deprecated [#279](https://github.com/bridgetownrb/bridgetown/pull/279) ([eclectic-coding](https://github.com/eclectic-coding))

## 0.20.0 - 2021-03-15

* EXPERIMENTAL (and opt-in): the Great Resource Content Engine PR has been merged. 135 files changed. Holy guacamole! [#243](https://github.com/bridgetownrb/bridgetown/pull/243) ([jaredcwhite](https://github.com/jaredcwhite)) [Read the Docs](https://www.bridgetownrb.com/docs/resources)
* Further improved Webpack integration by allowing multiple entry points and loading any manifest item with webpack_path helper [#247](https://github.com/bridgetownrb/bridgetown/pull/247) ([jaredcwhite](https://github.com/jaredcwhite)) [Docs](https://www.bridgetownrb.com/docs/frontend-assets#additional-bundled-assets-fonts-images)
* Exclude current post from LSI-powered related posts [#253](https://github.com/bridgetownrb/bridgetown/pull/253) ([katafrakt](https://github.com/katafrakt))
* The `inspect` string for `Bridgetown::Site` is now lean and clean.
* The history bug with the `bridgetown console` has been fixed! Now pressing your up arrow after entering the console will pull up all previous commands entered. Up, up, and away!
* Support added for upcoming gem `bridgetown-mdjs` which will allow inline JS code blocks in Markdown similar in purpose to MDX (but for web components and other HTML-native solutions). Stay tuned!

## 0.19.3 - 2021-02-11

* Fix css-loader's resolving of `/path/to/file` type URLs [#240](https://github.com/bridgetownrb/bridgetown/pull/240) ([jaredcwhite](https://github.com/jaredcwhite))
  * Add [documentation to explain why this change was necessary](https://www.bridgetownrb.com/docs/frontend-assets#additional-bundled-assets-fonts-images) and what it enables for the future regarding Webpack's bundling of images.

## 0.19.2 - 2021-02-05

* Introducing bundled configurations! Now some popular automations, including enhanced PostCSS and Tailwind CSS setups, are available directly through the Bridgetown CLI rather than being in a separate automations repo. [Documentation here](https://www.bridgetownrb.com/docs/bundled-configurations). Thanks [Ayush](https://github.com/ayushn21)
* Upgrade to Liquid 5.0 and remove previous backported `render` tag [#224](https://github.com/bridgetownrb/bridgetown/pull/224) ([jaredcwhite](https://github.com/jaredcwhite))
  * **Breaking Change:** when using the `where` filter, the literals `""``, `blank`, and `empty` are now all equivalent.
* New plugin generator now prefers `main` over `master` for default branch name [#225](https://github.com/bridgetownrb/bridgetown/pull/225) ([ayushn21](https://github.com/ayushn21))
* Use `ActiveSupport::DescendantsTracker` for managing class hierarchies of plugins (converters, builders, and generators) [#218](https://github.com/bridgetownrb/bridgetown/pull/218) ([jaredcwhite](https://github.com/jaredcwhite))
* Lots of documentation improvements — thanks [Juan](https://github.com/JuanVqz), [Taha](https://github.com/marketerly), and [Ayush](https://github.com/ayushn21).

## 0.19.1 - 2020-12-26

* Website: Fix a grammar error in the Jamstack.md page on Bridgetown website ([taha](https://github.com/marketerly))

* Fix for issue #73 (less likely to hit ActiveSupport error when `bridgetown` command is run without `bundle exec` prefixed)

## 0.19.0 - 2020-12-22

* Improve our active ActiveSupport support =) [#215](https://github.com/bridgetownrb/bridgetown/pull/215) ([jaredcwhite](https://github.com/jaredcwhite))
* Add `filters_scope` option to liquid_filter DSL [#214](https://github.com/bridgetownrb/bridgetown/pull/214) ([jaredcwhite](https://github.com/jaredcwhite))
* Deprecate `PageWithoutAFile` class. It will be removed in v0.20.
* Specify Webrick as a gem dependency now that it's no longer in the stdlib in Ruby 3
* Website: documentation on how to install Bridgetown in Fedora ([bkmgit](https://github.com/bkmgit))
* Add modules resolve paths to default webpack config [#206](https://github.com/bridgetownrb/bridgetown/pull/206) ([ayushn21](https://github.com/ayushn21))
* Add an empty PostCSS configuration option to the "new" command [#190](https://github.com/bridgetownrb/bridgetown/pull/190) ([ayushn21](https://github.com/ayushn21))
* Fix obfuscate link syntax [#203](https://github.com/bridgetownrb/bridgetown/pull/203) [julianrubisch](https://github.com/julianrubisch))
* Website: Fix class declaration keyword in liquid tags and helpers docs [#198](https://github.com/bridgetownrb/bridgetown/pull/198) ([ayushn21](https://github.com/ayushn21))
* Website: The Great Unification (removing all div-ision-s) [#191](https://github.com/bridgetownrb/bridgetown/pull/191) ([jaredcwhite](https://github.com/jaredcwhite))
* Website: Fix typo in generators page in docs [#195](https://github.com/bridgetownrb/bridgetown/pull/195) ([ayushn21](https://github.com/ayushn21))
* Add mailto:-<a>-tag to generated footer [#192](https://github.com/bridgetownrb/bridgetown/pull/192) ([pascalwengerter](https://github.com/pascalwengerter))
* Change the `name` attribute of the default `package.json` to be inferred from the path passed to `bridgetown new` [#188](https://github.com/bridgetownrb/bridgetown/pull/188) ([ayushn21](https://github.com/ayushn21))

## 0.18.6 - 2020-11-12

* Change the logging level for "Executing inline Ruby…" messages to the debug level [#184](https://github.com/bridgetownrb/bridgetown/pull/184) ([ianbayne](https://github.com/ianbayne))
* Add yarn clean script to package.json [#182](https://github.com/bridgetownrb/bridgetown/pull/182) ([andrewmcodes](https://github.com/andrewmcodes))
* Fix dash obfuscation in obfuscate filter [#181](https://github.com/bridgetownrb/bridgetown/pull/181) [julianrubisch](https://github.com/julianrubisch))
* Ensure HashWithDotAccess converts to Hash for Liquid templates

## 0.18.5 - 2020-11-09

* Bugfix: use HashWithDotAccess when parsing JSON in the HTTP Builder DSL

## 0.18.4 - 2020-11-05

* Bugfix: reset payload for each Liquid template conversion
* Change site.layouts hash to dot access

## 0.18.3 - 2020-11-01

* Bugfix: For template engine converters, set template_engine frontmatter automatically [#177](https://github.com/bridgetownrb/bridgetown/pull/177) ([jaredcwhite](https://github.com/jaredcwhite))

## 0.18.2 - 2020-10-30

* Bugfix: Resolve bug in converter error notifications

## 0.18.1 - 2020-10-29

* Bugfix: Use capture helper for liquid_render [#174](https://github.com/bridgetownrb/bridgetown/pull/174) ([jaredcwhite](https://github.com/jaredcwhite))

## 0.18.0 - 2020-10-29

* Configurable template engines on a per-site or per-document basis [#157](https://github.com/bridgetownrb/bridgetown/pull/157) ([jaredcwhite](https://github.com/jaredcwhite))
  * Set a `template_engine` key in your config file. The default is assumed to be liquid, but you can change it to `erb` (or other things in the future as this gets rolled out). Once that is set, you don't even have to name all your ERB files with an `.erb` extension—it will process even `.html.`, `.md`, `.json`, etc. It also means Liquid won't try to "preprocess" any ERB files, etc.
  * Regardless of what is configured site-wide, you can also set the `template_engine` in front matter (whether that's in an individual file or using front matter defaults), allowing you to swap out template engines wherever it's needed.
  * Front matter defaults support setting `template_engine` to none or anything else for a part of the source tree.
  * Liquid pages/layouts with a `.liquid` extension are processed as Liquid even if the configured engine is something else.
  * **Breaking change:** previously it was possible in Liquid for a child layout to set a front matter variable and a parent layout to access the child layout's variable value, aka `{{ layout.variable_from_child_layout }}`. That's no longer the case now…each layout has access to only its own front matter data.
  * **Breaking change:** a few pre-render hooks were provided access to Liquid's global payload hash. That meant they could alter the hash and thus the data being fed to Liquid templates. The problem is that there was no visibility into those changes from any other part of the system. Plugins accessing actual page/layout/site/etc. data wouldn't pick up those changes, nor would other template engines like ERB. Now if a hook needs to alter data, it needs to alter actual Ruby model data, and Liquid's payload should always reflect that model data.
* Add render method for Ruby templates [#169](https://github.com/bridgetownrb/bridgetown/pull/169) ([jaredcwhite](https://github.com/jaredcwhite))
  * Add Zeitwerk loaders for component folders (any `*.rb` file will now be accessible from Ruby templates). _Note:_ Zeitwerk will not load classes from plugins if they're already present in the source folder, so if you want a component to "reopen" a class from a plugin, you'll need to `require` the plugin class explicitly in your local component.
  * Allow ERB capture to pass object argument to its block.
  * **Breaking change:** the previous `<%|= output_block do %>…<%| end %>` block style is out in favor of: `<%= output_block do %>…<% end %>`, so you don't have to change a thing coming from Rails. _Note:_ if you're coming from Middleman where blocks output by default without `<%=`, you'll need to switch to Rails-style block expressions.
  * **Breaking change:** the `markdownify` helper in ERB now just returns a string rather than directly outputting to the template, so use `<%= markdownify do %>…<% end %>`.
* Site documents array should exclude static files [#168](https://github.com/bridgetownrb/bridgetown/pull/168) ([jaredcwhite](https://github.com/jaredcwhite))
* Obfuscate link filter [#167](https://github.com/bridgetownrb/bridgetown/pull/167) ([julianrubisch](https://github.com/julianrubisch))
* Add link/url_for and link_to helpers [#164](https://github.com/bridgetownrb/bridgetown/pull/164) ([jaredcwhite](https://github.com/jaredcwhite))
* False value in front matter is now supported to ensure no layout is rendered [#163](https://github.com/bridgetownrb/bridgetown/pull/163) ([jaredcwhite](https://github.com/jaredcwhite))
* Support per-document locale permalinks and config [#162](https://github.com/bridgetownrb/bridgetown/pull/162) ([jaredcwhite](https://github.com/jaredcwhite))
  * This isn't yet documented because an even more comprehensive i18n solution and announcement is forthcoming.
* Add blank src/images folder [#172](https://github.com/bridgetownrb/bridgetown/pull/172) ([jaredcwhite](https://github.com/jaredcwhite))
* chore: Prototype pages optimizations and improvements to YARD docs [#171](https://github.com/bridgetownrb/bridgetown/pull/171) ([jaredcwhite](https://github.com/jaredcwhite))

## 0.17.1 - 2020-10-02

* Use HashWithDotAccess::Hash for all data/config hashes [#158](https://github.com/bridgetownrb/bridgetown/pull/158) ([jaredcwhite](https://github.com/jaredcwhite))
* Add view reference to template helpers object [#153](https://github.com/bridgetownrb/bridgetown/pull/153) ([jaredcwhite](https://github.com/jaredcwhite))
* Support a _pages folder in the source tree [#151](https://github.com/bridgetownrb/bridgetown/pull/151) ([jaredcwhite](https://github.com/jaredcwhite))
* Add reading_time filter/helper [#150](https://github.com/bridgetownrb/bridgetown/pull/150) ([jaredcwhite](https://github.com/jaredcwhite))
* Rename pager variable to paginator [#148](https://github.com/bridgetownrb/bridgetown/pull/148) ([ParamagicDev](https://github.com/ParamagicDev) & [jaredcwhite](https://github.com/jaredcwhite))
* Add Class Map helper and usage info in docs [#147](https://github.com/bridgetownrb/bridgetown/pull/147) ([jaredcwhite](https://github.com/jaredcwhite))

## 0.17.0 "Mount Scott" - 2020-09-17

* Helper DSL for plugins (similar to the Liquid Filter DSL) [#135](https://github.com/bridgetownrb/bridgetown/pull/135) ([jaredcwhite](https://github.com/jaredcwhite))
* Process data cascade for folder-based frontmatter defaults [#139](https://github.com/bridgetownrb/bridgetown/pull/139) ([jaredcwhite](https://github.com/jaredcwhite))
* Execute block-based filters within object scope [#142](https://github.com/bridgetownrb/bridgetown/pull/142) ([jaredcwhite](https://github.com/jaredcwhite))
* Provide a Liquid find tag as easier alternative to where_exp [#101](https://github.com/bridgetownrb/bridgetown/pull/101) ([jaredcwhite](https://github.com/jaredcwhite))
* First pass at implementing site locales and translations [#131](https://github.com/bridgetownrb/bridgetown/pull/131) ([jaredcwhite](https://github.com/jaredcwhite))
* Add international character slug improvements [#138](https://github.com/bridgetownrb/bridgetown/pull/138) ([jaredcwhite](https://github.com/jaredcwhite) & [swanson](https://github.com/swanson))
* Switch to processing Ruby front matter by default [#136](https://github.com/bridgetownrb/bridgetown/pull/136) ([jaredcwhite](https://github.com/jaredcwhite))
* Switch from AwesomePrint to AmazingPrint [#127](https://github.com/bridgetownrb/bridgetown/pull/127) ([jaredcwhite](https://github.com/jaredcwhite))

## Website updates

* Fix filter plugin doc [#130](https://github.com/bridgetownrb/bridgetown/pull/130) ([julianrubisch](https://github.com/julianrubisch))
* Try out a couple of improvements for Lighthouse score [#128](https://github.com/bridgetownrb/bridgetown/pull/128) ([jaredcwhite](https://github.com/jaredcwhite))
* Adding netlify.toml to add caching & hint headers [#112](https://github.com/bridgetownrb/bridgetown/pull/112) ([MikeRogers0](https://github.com/MikeRogers0))

## 0.16.0 "Crystal Springs" - 2020-07-28

* Final release of 0.16! Yipee yay! Keep reading for what's new since 0.15.

## 0.16.0.beta2 - 2020-07-24

(`0-16-stable` branch)

* Fix the "add_yarn_for_gem" action [#114](https://github.com/bridgetownrb/bridgetown/pull/114) ([jaredcwhite](https://github.com/jaredcwhite))
* Call GitHub API to determine default branch name [#115](https://github.com/bridgetownrb/bridgetown/pull/115) ([jaredcwhite](https://github.com/jaredcwhite))
* Add capture helper to ERB templates
* Switch to Erubi for ERB template parsing
* Move webpack parsing code to the Utils module and enable for ERB templates [#105](https://github.com/bridgetownrb/bridgetown/pull/105) ([jaredcwhite](https://github.com/jaredcwhite))

## 0.16.0.beta1 - 2020-07-16

(`0-16-stable` branch)

* Improve handling of Webpack manifest errors [#96](https://github.com/bridgetownrb/bridgetown/pull/96) ([ParamagicDev](https://github.com/ParamagicDev))
* Add a class_map Liquid tag [#99](https://github.com/bridgetownrb/bridgetown/pull/99) ([ParamagicDev](https://github.com/ParamagicDev))
* Update pagination documentation [#98](https://github.com/bridgetownrb/bridgetown/pull/98) ([andrewmcodes](https://github.com/andrewmcodes))
* Add ERB template support (with Slim/Haml coming as additional plugins) [#79](https://github.com/bridgetownrb/bridgetown/pull/79) ([jaredcwhite](https://github.com/jaredcwhite))
* Add/update Yard documentation for Site concerns [#85](https://github.com/bridgetownrb/bridgetown/pull/85) ([ParamagicDev](https://github.com/ParamagicDev))
* Resolve deprecation warnings for Ruby 2.7 [#92](https://github.com/bridgetownrb/bridgetown/pull/92) ([jaredcwhite](https://github.com/jaredcwhite))
* Switched the default branch from master to main
* Remove the Convertible concern and refactor into additional concerns [#80](https://github.com/bridgetownrb/bridgetown/pull/80) ([jaredcwhite](https://github.com/jaredcwhite))
* Reducing animation for users who prefer reduced motion [#84](https://github.com/bridgetownrb/bridgetown/pull/84) ([MikeRogers0](https://github.com/MikeRogers0))

## 0.15.0 "Overlook" - 2020-06-18

* Final release of 0.15! Woo hoo! Keep reading for what's new since 0.14

## 0.15.0.beta4 - 2020-06-15

(`0-15-stable` branch)

* Add documentation for Cypress testing [#75](https://github.com/bridgetownrb/bridgetown/pull/75) ([ParamagicDev](https://github.com/ParamagicDev))
* Add missing related_posts to Document drop [#78](https://github.com/bridgetownrb/bridgetown/pull/78) ([jaredcwhite](https://github.com/jaredcwhite))
* Use AwesomePrint gem for console [#76](https://github.com/bridgetownrb/bridgetown/pull/76) ([jaredcwhite](https://github.com/jaredcwhite))

## 0.15.0.beta3 - 2020-06-05

(`0-15-stable` branch)

* New documentation on plugin development (including `bridgetown plugins new`), themes, automations, Liquid components, etc. [now on beta website](https://beta.bridgetownrb.com). Beta site also showcases the upcoming quick search plugin which will be made available to all site devs.
* Optimizations made internally to the Bridgetown test suite.
* Bridgetown website experiment with test suite [#69](https://github.com/bridgetownrb/bridgetown/pull/69) ([jaredcwhite](https://github.com/jaredcwhite))
* Fix for GitHub branch URLs in automations [#66](https://github.com/bridgetownrb/bridgetown/pull/66) ([ParamagicDev](https://github.com/ParamagicDev))
* Migrate CLI from Mercenery to Thor and Enable Automations [#56](https://github.com/bridgetownrb/bridgetown/pull/56) ([jaredcwhite](https://github.com/jaredcwhite))
* First implementation of Liquid Components as well as a preview tool on the Bridgetown website [#26](https://github.com/bridgetownrb/bridgetown/pull/26) ([jaredcwhite](https://github.com/jaredcwhite))
* Deprecate the include tag and standardize around the render tag [#46](https://github.com/bridgetownrb/bridgetown/pull/46) ([jaredcwhite](https://github.com/jaredcwhite))

## 0.14.1 - 2020-05-23

* Patch to fix PluginManager `yarn add` bug when there is no `dependencies` key in `package.json`

## 0.14.0 "Hazelwood" - 2020-05-17

* Use `liquid-render-tag` backport gem and remove references to temporary GitHub fork of Liquid [#52](https://github.com/bridgetownrb/bridgetown/pull/52) ([jaredcwhite](https://github.com/jaredcwhite))
* Refactor `Bridgetown::Site` into multiple Concerns [#51](https://github.com/bridgetownrb/bridgetown/pull/51) ([jaredcwhite](https://github.com/jaredcwhite))
* Fix for `start.js` to eliminate junk terminal characters ([jaredcwhite](https://github.com/jaredcwhite))
* New Unified Plugins API with Builders, Source Manifests, and Autoreload [#41](https://github.com/bridgetownrb/bridgetown/pull/41) ([jaredcwhite](https://github.com/jaredcwhite))
* Add a Posts page to the new site template [#39](https://github.com/bridgetownrb/bridgetown/pull/39) ([andrewmcodes](https://github.com/andrewmcodes))
* Add `titleize` Liquid filter and improve `slugify` filter description [#38](https://github.com/bridgetownrb/bridgetown/pull/38) ([jaredcwhite](https://github.com/jaredcwhite))
* Add Bundler cache to the build GH action to improve test speed [#40](https://github.com/bridgetownrb/bridgetown/pull/40) ([andrewmcodes](https://github.com/andrewmcodes))
* Bump minimum Node requirement to 10.13 ([jaredcwhite](https://github.com/jaredcwhite))

## 0.13.0 "Klickitat" - 2020-05-05

* Configurable setting to allow executable Ruby code in Front Matter [#9](https://github.com/bridgetownrb/bridgetown/pull/9)
* Honor the configured site encoding when loading Liquid components [#33](https://github.com/bridgetownrb/bridgetown/pull/33)
* Allow configuration file as well as site metadata file to pull YAML options out of an environment specific block [#34](https://github.com/bridgetownrb/bridgetown/pull/34)
* Add Faraday to the default set of gems that get installed with Bridgetown [#30](https://github.com/bridgetownrb/bridgetown/pull/30)
* Add blank favicon.ico file to prevent error when generating a new site for the first time [#32](https://github.com/bridgetownrb/bridgetown/pull/32) ([jaredmoody](https://github.com/jaredmoody))

## 0.12.1 - 2020-05-01

* Update the minimum Ruby version requirement to 2.5

## 0.12.0 "Lovejoy" - 2020-04-27

* Add Concurrently and Browsersync for live reload, plus add new Yarn scripts [#21](https://github.com/bridgetownrb/bridgetown/pull/21)
* Add some color to terminal output
* Add code name for minor SemVer version updates

## 0.11.2 - 2020-04-24

* Add components source folder to sass-loader include paths
* Include missing commit from PR #14

## 0.11.1 - 2020-04-24

* Add a git init step to `bridgetown new` command [#18](https://github.com/bridgetownrb/bridgetown/pull/18)
* Update sass-loader webpack config to support .sass [#14](https://github.com/bridgetownrb/bridgetown/pull/14) ([jaredmoody](https://github.com/jaredmoody)) 
* Add customizable permalinks to Prototype Pages (aka `/path/to/:term/and/beyond`). Use hooks and in-memory caching to speed up Pagination. _Inspired by [use cases like this](https://annualbeta.com/blog/dynamic-social-sharing-images-with-eleventy/)…_ [#12](https://github.com/bridgetownrb/bridgetown/pull/12)

## 0.11.0 - 2020-04-21

**Prototype Pages**

You can now create a page, say `categories/category.html`, and add a `prototype` config
to the Front Matter:

```yaml
layout: default
title: Posts in category :prototype-term
prototype:
  term: category
```

And then all the site's different categories will have archives pages at this location
(e.g. `categories/awesome-movies`, `categories/my-cool-vacation`, etc.) It enables
pagination automatically, so you'd just use `paginator.documents` to loop through the
posts. [See the docs here.](https://www.bridgetown.com/docs/prototype-pages)

[#11](https://github.com/bridgetownrb/bridgetown/pull/11)

## 0.10.2 - 2020-04-19

**Automatic Yarn Step for New Plugins**

Now with Gem-based plugins for Bridgetown, all you need to do is add `yarn-add`
metadata matching the NPM package name and keep the version the same as the Gem
version. For example:

```ruby
  spec.metadata = { "yarn-add" => "my-awesome-plugin@#{MyAwesomePlugin::VERSION}" }
```

With that bit of metadata, Bridgetown will know always to look for that package in
the users' `package.json` file when they load Bridgetown, and it will trigger a
`yarn add` command if the package and exact version number isn't present.

## 0.10.1 - 2020-04-18

Add `{% webpack_path [js|css] }` tag which pulls in the Webpack manifest and finds
the hashed output bundles. Also works in concert with the Watcher so every time
Webpack rebuilds the bundles, Bridgetown regenerates the site.

[#6](https://github.com/bridgetownrb/bridgetown/pull/6)

## 0.10.0 - 2020-04-17

**Switch gears on _experimental_ component functionality.**

Going with a new `rendercontent` tag instead of `component`. It is based on
Shopify's new Render tag which recently got introduced to Liquid. Note that the
feature hasn't been officially released via the Liquid gem, so we need to use the
main branch that's been forked on GitHub with a higher version number).

[#5](https://github.com/bridgetownrb/bridgetown/pull/5)

## 0.9.0 - 2020-04-16

  * Update table styling in Documentation
  * Now showing the plugins_dir in log output if it's present
  * With the Posts Reader changes, now you can add a Front Matter Default of
    `_posts/drafts` having `published: false`, put a bunch of draft posts in
    `_posts/drafts` and you're done!
  * New `-U` flag makes it easier to specify generating `published: false` docs.
  * The Posts Reader has been reworked so that files with valid front matter can
    be read in even if there's no YYYY-MM-DD- at the beginning. In addition, static
    files are also supported, which means if you can create a folder (`inlinefiles`),
    drop a post in along with a bunch of images, and use `![alt](some-image.jpg)`
    relative paths, it'll work! Big improvement to Markdown authoring. (You'll need
    to use a permalink in a specific manner though, e.g.
    `permalink: /inlinefiles/:title:output_ext`)
    If you need a static file not to get copied to the destination, just add an
    `_` at the beginning and it'll get ignored.
  * Collections no longer allow displaying a full server file path via Liquid.
  * `{{ page.collection }}` now returns a CollectionDrop, not the label of
    the collection. Using the `jsonify` filter on a document however still returns
    just the label for the `collection` key.
  * Add favicon to website
  * Add mobile improvements to website
  * Add back working feature tests for basic pagination
  * Convert to Ruby 1.9+ `symbol: value` hash syntax
  * Add [Swup](https://swup.js.org) to website for some slick transitions
  * Add "where_query" feature to Paginate. For example. specify `where_query: [author, sandy]` in the pagination YAML to filter by that front matter key.
  * Update the Jamstack page in the docs.

## 0.8.1 - 2020-04-14

  * Fix bug where paginator wouldn't properly convert Markdown templates

## 0.8.0 - 2020-04-14

  * Add Bridgetown::Paginate gem to monorepo
  * Add CI build workflow via GitHub actions
  * Clean up Rake tasks
  * Add documentation around gem releases and contributing PRs

## 0.7.0 - 2020-04-12

  * Moved the default plugins folder from `src/_plugins` to simply `plugins`
  * Remove `gems` and `plugins` keys from configuration
  * Move the cache and metadata folders to the root dir
  * Define a default data file for site metadata: `src/_data/site_metdata.yml`
    that's accessible via `{{ site.metadata.title }}` (for example)
  * Add relevant changes to site template for `bridgetown new`
  * Continue work on repo cleanup and documentation

## 0.6.0 - 2020-04-09

  * Add `bridgetown console` command to invoke IRB with the current site (similar to the Rails console command). Plugins, gems, will be loaded, etc.

## 0.5.0 - 2020-04-07

  * Remove `em-websocket` dependency.
  * Change _config.yml to bridgetown.config.yml (but _config.yml will still work for compatibility purposes).
  * New Bridgetown logo and further Bridgetown URL updates.
  * Many new and improved docs.

## 0.4.0 - 2020-04-05

  * Added a `component` Liquid tag which extends the functionality of include tags.
  * Added a new `bridgetown-website` project to the repo, which of course is a Bridgetown site and will house the homepage, documentation, etc.

## 0.3.0 - 2020-04-05

  * Moved all Bridgetown code to `bridgetown-core`, the idea being this will now be a monorepo housing Core plus a few other official gems/projects as time goes on. Users will install the `bridgetown` gem which in turns installs `bridgetown-core` as a dependency.

## 0.2.0 - 2020-04-04

  * Completed comprehensive code audio and changed or removed features no
    longer required for the project. Fixed and successfully ran test suite
    accordingly.

## 0.1.0 - 2020-04-02

  * First version after fork from pre-released Jekyll 4.1

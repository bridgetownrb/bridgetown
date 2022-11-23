# frozen_string_literal: true

`bundle lock --add-platform x86_64-linux`
copy_file in_templates_dir("gh-pages.yml"), ".github/workflows/gh-pages.yml"

# rubocop:disable Layout/LineLength
say "🎉 A GitHub action to deploy your site to GitHub pages has been configured!"
say ""

say "🛠️  After pushing the action, go to your repository settings and configure GitHub Pages to deploy from GitHub Actions."
say ""

say "You'll likely also need to set `base_path` in your `bridgetown.config.yml` to your repository's name. If you do this you'll need to use the `relative_url` helper for all links and assets in your HTML."
say "If you're using esbuild for frontend assets, edit `esbuild.config.js` to update `publicPath`."
say ""
# rubocop:enable Layout/LineLength

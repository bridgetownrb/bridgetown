# frozen_string_literal: true

Bridgetown.initializer :local_ssr_init do |config|
  config.init :ssr do
    sessions cookie_options: { same_site: :strict }
    setup -> site do # rubocop:disable Layout/SpaceInLambdaLiteral, Style/StabbyLambdaParentheses
      site.data.iterations ||= 0
      site.data.iterations += 1
    end
  end
end

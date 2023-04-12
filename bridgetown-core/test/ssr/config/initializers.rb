# frozen_string_literal: true

Bridgetown.configure do
  # attempt multiple inits just to ensure it is idempotent
  init :local_ssr_init, require_gem: false
  init :local_ssr_init, require_gem: false
  init :local_ssr_init, require_gem: false
end

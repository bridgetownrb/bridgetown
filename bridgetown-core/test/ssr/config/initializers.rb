# frozen_string_literal: true

Bridgetown.configure do
  init :ssr do
    setup ->(site) do
      site.data.iterations ||= 0
      site.data.iterations += 1
    end
  end
end

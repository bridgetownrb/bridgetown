module MySite
  module UrlFilters
    def cache_busting_url(input)
      "http://www.example.com/#{input}?#{Time.now.to_i}"
    end
  end
end

Liquid::Template.register_filter(MySite::UrlFilters)
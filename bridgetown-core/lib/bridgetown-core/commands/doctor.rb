# frozen_string_literal: true

module Bridgetown
  module Commands
    class Doctor < Thor::Group
      extend BuildOptions
      extend Summarizable
      include ConfigurationOverridable

      Registrations.register do
        register(Doctor, "doctor", "doctor", Doctor.summary)
      end

      def self.banner
        "bridgetown doctor [options]"
      end
      summary "Search site and print specific deprecation warnings"

      def doctor
        site = Bridgetown::Site.new(configuration_with_overrides(options))
        site.reset
        site.read
        site.generate

        if healthy?(site)
          Bridgetown.logger.info "Your test results", "are in. Everything looks fine."
        else
          abort
        end
      end

      protected

      def healthy?(site)
        [
          !conflicting_urls(site),
          !urls_only_differ_by_case(site),
          proper_site_url?(site),
          properly_gathered_posts?(site),
        ].all?
      end

      def properly_gathered_posts?(site)
        return true if site.config["collections_dir"].empty?

        posts_at_root = site.in_source_dir("_posts")
        return true unless File.directory?(posts_at_root)

        Bridgetown.logger.warn "Warning:",
                               "Detected '_posts' directory outside custom `collections_dir`!"
        Bridgetown.logger.warn "",
                               "Please move '#{posts_at_root}' into the custom directory at " \
                               "'#{site.in_source_dir(site.config["collections_dir"])}'"
        false
      end

      def conflicting_urls(site)
        conflicting_urls = false
        urls = {}
        urls = collect_urls(urls, site.contents, site.dest)
        urls.each do |url, paths|
          next unless paths.size > 1

          conflicting_urls = true
          Bridgetown.logger.warn "Conflict:", "The URL '#{url}' is the destination " \
                                              "for the following pages: #{paths.join(", ")}"
        end
        conflicting_urls
      end

      def urls_only_differ_by_case(site)
        urls_only_differ_by_case = false
        urls = case_insensitive_urls(site.resources, site.dest)
        urls.each_value do |real_urls|
          next unless real_urls.uniq.size > 1

          urls_only_differ_by_case = true
          Bridgetown.logger.warn(
            "Warning:",
            "The following URLs only differ by case. On a case-insensitive file system one of " \
            "the URLs will be overwritten by the other: #{real_urls.join(", ")}"
          )
        end
        urls_only_differ_by_case
      end

      def proper_site_url?(site)
        url = site.config["url"]
        [
          url_exists?(url),
          url_valid?(url),
          url_absolute(url),
        ].all?
      end

      private

      def collect_urls(urls, things, destination)
        things.each do |thing|
          dest = thing.method(:destination).arity == 1 ?
                   thing.destination(destination) :
                   thing.destination
          if urls[dest]
            urls[dest] << thing.path
          else
            urls[dest] = [thing.path]
          end
        end
        urls
      end

      def case_insensitive_urls(things, _destination)
        things.each_with_object({}) do |thing, memo|
          dest = thing.destination&.output_path
          (memo[dest.downcase] ||= []) << dest if dest
        end
      end

      def url_exists?(url)
        return true unless url.nil? || url.empty?

        Bridgetown.logger.warn "Warning:", "You didn't set an URL in the config file, " \
                                           "you may encounter problems with some plugins."
        false
      end

      def url_valid?(url)
        Addressable::URI.parse(url)
        true
      # Addressable::URI#parse only raises a TypeError
      # https://git.io/vFfbx
      rescue TypeError
        Bridgetown.logger.warn "Warning:", "The site URL does not seem to be valid, " \
                                           "check the value of `url` in your config file."
        false
      end

      def url_absolute(url)
        return true if url.is_a?(String) && Addressable::URI.parse(url).absolute?

        Bridgetown.logger.warn "Warning:", "Your site URL does not seem to be absolute, " \
                                           "check the value of `url` in your config file."
        false
      end
    end
  end
end

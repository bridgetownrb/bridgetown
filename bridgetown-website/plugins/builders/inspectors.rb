class Builders::Inspectors < SiteBuilder
  def build
    inspect_html do |document|
      document.query_selector_all("article h2[id], article h3[id]").each do |heading|
        heading << document.create_text_node(" ")
        heading << document.create_element(
          "a", "#",
          href: "##{heading[:id]}",
          class: "heading-anchor"
        )
      end
    end

    # LintHTML replacement to find div/span tags
    inspect_html do |document, resource|
      class_allow_list = (
        Array(site.config.divicide&.allowed_classes) + %w[highlighter-rouge highlight]
      ).uniq

      tags = document.query_selector_all("div, span")
        .reject do |tag|
          (tag.classes & class_allow_list).present? || tag["slot"] ||
            tag.ancestors("div, span").any? do |parent|
              (parent.classes & class_allow_list).present?
            end
        end

      if tags.length.positive?
        logger = Bridgetown.logger
        msg = "Linting error: #{resource.relative_path} includes a div or span tag. " \
              "Please replace with a semantic tag name."

        Bridgetown.env.production? ? logger.error(msg) && exit(1) : logger.warn(msg)
      end
    end
  end
end

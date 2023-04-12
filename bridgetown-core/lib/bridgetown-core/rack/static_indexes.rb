# frozen_string_literal: true

require "roda/plugins/public"

# TODO: extract out to a standalone Roda plugin
Roda::RodaPlugins::Public::RequestMethods.module_eval do
  SPLIT = Regexp.union(*[File::SEPARATOR, File::ALT_SEPARATOR].compact) # rubocop:disable Lint/ConstantDefinitionInBlock
  def public_path_segments(path) # rubocop:disable Metrics/CyclomaticComplexity, Metrics/PerceivedComplexity
    segments = []

    path.split(SPLIT).each do |seg|
      next if seg.empty? || seg == "."

      seg == ".." ? segments.pop : segments << seg
    end

    path = File.join(roda_class.opts[:public_root], *segments)
    unless File.file?(path)
      path = File.join(path, "index.html")
      if File.file?(path)
        segments << "index.html"
      else
        segments[segments.size - 1] = "#{segments.last}.html"
      end
    end

    segments
  rescue IndexError
    nil
  end
end

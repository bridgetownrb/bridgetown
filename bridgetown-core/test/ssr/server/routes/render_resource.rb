# frozen_string_literal: true

class Routes::RenderResource < Bridgetown::Rack::Routes
  route do |r|
    # route: GET /render_resource
    r.get "render_resource" do
      # Roda should know how to autorender the resource
      bridgetown_site.collections.pages.resources.find { _1.id == "repo://pages.collection/index.md" }
    end

    r.get "render_model" do
      # Roda should know how to autorender the model as a resource
      Bridgetown::Model::Base.find("repo://pages.collection/test_doc.md")
    end
  end
end

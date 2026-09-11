# frozen_string_literal: true

module Terminus
  module Actions
    module Devices
      # The index action.
      class Index < Action
        include Deps[:htmx, repository: "repositories.device"]

        def handle request, response
          query = request.params[:query].to_s
          devices = load query

          if htmx.request? request.env, :source, "input#search"
            add_htmx_headers response, query
            response.render view, devices:, query:, layout: false
          else
            response.render view, devices:, query:
          end
        end

        private

        def load query
          query.empty? ? repository.all : repository.search(:label, query)
        end

        def add_htmx_headers response, query
          return if query.empty?

          htmx.response! response.headers, push_url: routes.path(:devices, query:)
        end
      end
    end
  end
end

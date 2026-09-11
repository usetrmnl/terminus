# frozen_string_literal: true

module Terminus
  module Actions
    module Users
      # The index action.
      class Index < Action
        include Deps[:htmx, repository: "repositories.user"]

        def handle request, response
          query = request.params[:query].to_s
          users = load query

          if htmx.request? request.env, :source, "input#search"
            add_htmx_headers response, query
            response.render view, users:, query:, layout: false
          else
            response.render view, users:, query:
          end
        end

        private

        def load(query) = query.empty? ? repository.all : repository.search(:name, query)

        def add_htmx_headers response, query
          return if query.empty?

          htmx.response! response.headers, push_url: routes.path(:users, query:)
        end
      end
    end
  end
end

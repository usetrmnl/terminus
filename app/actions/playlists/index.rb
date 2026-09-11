# frozen_string_literal: true

module Terminus
  module Actions
    module Playlists
      # The index action.
      class Index < Action
        include Deps[:htmx, repository: "repositories.playlist"]

        def handle request, response
          query = request.params[:query].to_s
          playlists = load query

          if htmx.request? request.env, :source, "input#search"
            add_htmx_headers response, query
            response.render view, playlists:, query:, layout: false
          else
            response.render view, playlists:, query:
          end
        end

        private

        def load(query) = query.empty? ? repository.all : repository.search(:label, query)

        def add_htmx_headers response, query
          return if query.empty?

          htmx.response! response.headers, push_url: routes.path(:playlists, query:)
        end
      end
    end
  end
end

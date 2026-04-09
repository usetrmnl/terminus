# frozen_string_literal: true

require "refinements/hash"

module Terminus
  module Actions
    module Extensions
      module Poll
        # The show action.
        class Show < Action
          include Deps[
            repository: "repositories.extension",
            fetcher: "aspects.extensions.fetchers.many"
          ]
          include Initable[json_formatter: Aspects::JSONFormatter]

          using Refinements::Hash

          params { required(:extension_id).filled :integer }

          def handle request, response
            extension = repository.find request.params[:extension_id]

            halt :not_found unless extension

            render extension, response
          end

          private

          def render extension, response
            result = fetcher.call extension

            if result.success?
              response.render view, content: json_formatter.call(result.success), layout: false
            else
              response.render view,
                              content: "Unable to render content. Please check your exchanges.",
                              layout: false
            end
          end
        end
      end
    end
  end
end

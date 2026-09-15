# frozen_string_literal: true

require "refinements/hash"

module Terminus
  module Actions
    module Extensions
      # The create action.
      class Create < Action
        include Deps[
          :htmx_layout,
          "aspects.extensions.creator",
          validator: "contracts.extensions.create",
          repository: "repositories.extension",
          index_view: "views.extensions.index"
        ]

        using Refinements::Hash

        def handle request, response
          case creator.call(request.params.to_h, validator:)
            in Success then success request, response
            in Failure(result) then failure result, response
          end
        end

        private

        def success request, response
          response.render index_view, extensions: repository.all, layout: htmx_layout.call(request)
        end

        def failure result, response
          fields = result[:extension].transform_with!(
            start_at: -> value { value.strftime("%Y-%m-%dT%H:%M:%S") }
          )

          response.render view, fields:, errors: result.errors[:extension], layout: false
        end
      end
    end
  end
end

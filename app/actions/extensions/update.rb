# frozen_string_literal: true

require "refinements/hash"

module Terminus
  module Actions
    module Extensions
      # The update action.
      class Update < Action
        include Deps[
          "aspects.errors.detailer",
          "aspects.extensions.updater",
          validator: "contracts.extensions.update"
        ]

        using Refinements::Hash

        def handle request, response
          case updater.call(request.params.to_h, validator:)
            in Success(extension) then success extension, response
            in Failure(String) then halt :unprocessable_content
            in Failure(*tuple) then failure(*tuple, response)
          end
        end

        private

        def success extension, response
          response.flash[:notice] = translate ".notice"
          response.redirect_to routes.path(:extension_edit, id: extension.id)
        end

        def failure extension, result, response
          errors = result.errors[:extension]
          fields = result[:extension].transform_with!(
            start_at: -> value { value.strftime("%Y-%m-%dT%H:%M:%S") }
          )

          response.flash.now[:alert] = detailer.call errors, "Extension "
          response.render view, extension:, fields:, errors:
        end
      end
    end
  end
end

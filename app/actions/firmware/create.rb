# frozen_string_literal: true

module Terminus
  module Actions
    module Firmware
      # The create action.
      class Create < Action
        include Deps[
          :htmx,
          creator: "aspects.firmware.creator",
          repository: "repositories.firmware",
          index_view: "views.firmware.index"
        ]

        params do
          required(:firmware).filled :hash do
            required(:version).filled Types::Version
            required(:attachment).filled Schemas::Attachment
          end

          required(:model_ids).filled(:array).each(:integer)
        end

        def handle request, response
          parameters = request.params
          attachment = parameters.dig :firmware, :attachment, :tempfile

          case creator.call parameters.to_h, attachment, validator: contract
            in Success then response.render index_view, firmware: repository.all
            in Failure(result) then error result, response
          end
        end

        private

        def error result, response
          response.render view,
                          firmware: nil,
                          fields: result[:firmware],
                          errors: result.errors[:firmware]
        end
      end
    end
  end
end

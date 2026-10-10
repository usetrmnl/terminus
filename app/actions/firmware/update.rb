# frozen_string_literal: true

module Terminus
  module Actions
    module Firmware
      # The update action.
      class Update < Action
        include Deps["aspects.firmware.updater", repository: "repositories.firmware"]

        params do
          required(:id).filled :integer

          required(:firmware).filled :hash do
            required(:version).filled Types::Version
            optional(:attachment).filled Schemas::Attachment
          end

          required(:model_ids).filled(:array).each(:integer)
        end

        def handle request, response
          parameters = request.params
          record = repository.find parameters[:id]
          io = parameters.dig :firmware, :attachment, :tempfile

          case updater.call parameters.to_h, io, validator: contract
            in Success then response.redirect_to routes.path(:firmware, id: record.id)
            in Failure(result) then error record, result, response
          end
        end

        private

        def error record, result, response
          response.render view,
                          firmware: record,
                          fields: result[:firmware],
                          errors: result.errors[:firmware]
        end
      end
    end
  end
end

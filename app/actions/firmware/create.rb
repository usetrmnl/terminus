# frozen_string_literal: true

module Terminus
  module Actions
    module Firmware
      # The create action.
      class Create < Action
        include Deps[
          :htmx,
          repository: "repositories.firmware",
          index_view: "views.firmware.index"
        ]

        params do
          required(:firmware).filled :hash do
            required(:version).filled Types::Version
            required(:attachment).filled Schemas::Attachment
          end
        end

        def handle request, response
          parameters = request.params

          if parameters.valid?
            save parameters[:firmware]
            response.render index_view, firmware: repository.all
          else
            error response, parameters
          end
        end

        private

        # :reek:FeatureEnvy
        def save attributes
          attachment = attributes.delete :attachment
          record = repository.create attributes

          record.upload attachment[:tempfile], metadata: {"filename" => "#{record.version}.bin"}
          repository.update record.id, attachment_data: record.attachment_attributes
        end

        def error response, parameters
          response.render view,
                          firmware: nil,
                          fields: parameters[:firmware],
                          errors: parameters.errors[:firmware]
        end
      end
    end
  end
end

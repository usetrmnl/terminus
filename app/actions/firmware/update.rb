# frozen_string_literal: true

module Terminus
  module Actions
    module Firmware
      # The update action.
      class Update < Action
        include Deps[repository: "repositories.firmware"]

        params do
          required(:id).filled :integer

          required(:firmware).filled :hash do
            required(:version).filled Types::Version
            required(:kind).filled :string
            optional(:attachment).filled Schemas::Attachment
          end
        end

        def handle request, response
          parameters = request.params
          record = repository.find parameters[:id]

          halt :unprocessable_content unless record

          if parameters.valid?
            save record, parameters, response
          else
            error record, parameters, response
          end
        end

        private

        # :reek:TooManyStatements
        def save record, parameters, response
          id = record.id
          attributes = parameters[:firmware]
          attachment = attributes.delete :attachment

          repository.update id, **attributes
          attach record, attachment
          response.redirect_to routes.path(:firmware, id:)
        end

        # :reek:FeatureEnvy
        def attach record, attachment
          return unless attachment

          record.replace attachment[:tempfile], metadata: {"filename" => "#{record.version}.bin"}
          repository.update record.id, attachment_data: record.attachment_attributes
        end

        def error record, parameters, response
          response.render view,
                          firmware: record,
                          fields: parameters[:firmware],
                          errors: parameters.errors[:firmware]
        end
      end
    end
  end
end

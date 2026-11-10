# frozen_string_literal: true

module Terminus
  module Actions
    module Screens
      # The update action.
      class Update < Action
        include Deps[repository: "repositories.screen", model_repository: "repositories.model"]

        contract Contracts::Screens::Update

        def handle request, response
          parameters = request.params
          screen = repository.find parameters[:id]

          halt :unprocessable_content unless screen

          if parameters.valid?
            save screen, parameters, response
          else
            error screen, parameters, response
          end
        end

        private

        def save record, parameters, response
          id = record.id
          attributes = parameters[:screen]
          image = attributes.delete :image

          repository.update id, **attributes
          attach record, image
          response.redirect_to routes.path(:screen, id:)
        end

        def attach record, image
          return unless image

          tempfile = image[:tempfile]
          extension = File.extname tempfile

          record.replace tempfile, metadata: {"filename" => "#{record.name}#{extension}"}
          repository.update record.id, image_data: record.image_attributes
        end

        def error screen, parameters, response
          response.render view,
                          models: model_repository.all,
                          screen:,
                          fields: parameters[:screen],
                          errors: parameters.errors[:screen]
        end
      end
    end
  end
end

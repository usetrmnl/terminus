# frozen_string_literal: true

module Terminus
  module Actions
    module Screens
      # The create action.
      class Create < Action
        include Deps[
          :htmx,
          repository: "repositories.screen",
          model_repository: "repositories.model",
          index_view: "views.screens.index"
        ]

        contract Contracts::Screens::Create

        protected

        def handle request, response
          parameters = request.params

          if parameters.valid?
            save parameters[:screen]
            response.render index_view, screens: repository.all
          else
            render_errors request, response
          end
        end

        def render_errors request, response
          parameters = request.params

          response.render view,
                          models: model_repository.all,
                          screen: nil,
                          fields: parameters[:screen],
                          errors: parameters.errors[:screen]
        end

        private

        def save attributes
          image = attributes.delete :image
          record = repository.create attributes
          tempfile = image[:tempfile]
          extension = File.extname tempfile

          record.upload tempfile, metadata: {"filename" => "#{record.name}#{extension}"}
          repository.update record.id, image_data: record.image_attributes
        end
      end
    end
  end
end

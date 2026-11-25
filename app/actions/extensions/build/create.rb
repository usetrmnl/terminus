# frozen_string_literal: true

module Terminus
  module Actions
    module Extensions
      module Build
        # The create action.
        class Create < Action
          include Deps[:htmx, :htmx_layout, repository: "repositories.extension"]
          include Initable[job: Jobs::Batches::Extension]

          params { required(:id).filled :integer }

          protected

          def handle request, response
            extension = repository.find request.params[:id]
            enqueue request, extension, response
          end

          private

          def enqueue request, extension, response
            job.perform_async extension.id

            response.status = 202
            response.render view, extension:, layout: htmx_layout.call(request)
          end
        end
      end
    end
  end
end

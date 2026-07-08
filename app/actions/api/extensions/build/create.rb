# frozen_string_literal: true

module Terminus
  module Actions
    module API
      module Extensions
        module Build
          # The create action.
          class Create < Base
            include Deps[repository: "repositories.extension"]
            include Initable[job: Jobs::Batches::Extension]

            params { required(:extension_id).filled :integer }

            def handle request, response
              extension = repository.find request.params[:extension_id]

              if extension
                enqueue extension, response
              else
                response.body = petail[status: :not_found].to_json
              end
            end

            private

            def enqueue extension, response
              job.perform_async extension.id

              response.status = 202
              response.body = {data: {id: extension.id, enqueued: true}}.to_json
            end
          end
        end
      end
    end
  end
end

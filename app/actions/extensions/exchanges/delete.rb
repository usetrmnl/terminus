# frozen_string_literal: true

module Terminus
  module Actions
    module Extensions
      module Exchanges
        # The delete action.
        class Delete < Action
          include Deps[repository: "repositories.extension_exchange"]

          params do
            required(:extension_id).filled :integer
            required(:id).filled :integer
          end

          def handle request, response
            parameters = request.params

            halt :unprocessable_content unless parameters.valid?

            record = repository.find_by(**parameters)

            repository.delete record.id
            response.body = ""
          end
        end
      end
    end
  end
end

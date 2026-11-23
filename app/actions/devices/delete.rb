# frozen_string_literal: true

module Terminus
  module Actions
    module Devices
      # The delete action.
      class Delete < Action
        include Deps["aspects.devices.deleter"]

        params { required(:id).filled :integer }

        protected

        def handle request, response
          parameters = request.params

          halt :unprocessable_content unless parameters.valid?

          deleter.call parameters[:id]
          response.body = ""
        end
      end
    end
  end
end

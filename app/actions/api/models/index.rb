# frozen_string_literal: true

module Terminus
  module Actions
    module API
      module Models
        # The index action.
        class Index < Base
          include Deps[repository: "repositories.model"]
          include Initable[serializer: Serializers::Model]

          protected

          def handle *, response
            data = repository.all.map { serializer.new(it).to_h }
            response.body = {data:}.to_json
          end
        end
      end
    end
  end
end

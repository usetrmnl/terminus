# frozen_string_literal: true

module Terminus
  module Actions
    module API
      module Extensions
        # The index action.
        class Index < Base
          include Deps[repository: "repositories.extension"]
          include Initable[serializer: Serializers::Extension]

          def handle(*, response) = response.body = {data:}.to_json

          private

          def data = repository.all.map { serializer.new(it).to_h }
        end
      end
    end
  end
end

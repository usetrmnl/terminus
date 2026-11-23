# frozen_string_literal: true

module Terminus
  module Actions
    module API
      module Playlists
        # The index action.
        class Index < Base
          include Deps[repository: "repositories.playlist"]
          include Initable[serializer: Serializers::Playlist]

          protected

          def handle *, response
            data = repository.with_items.to_a.map { serializer.new(it).to_h }
            response.body = {data:}.to_json
          end
        end
      end
    end
  end
end

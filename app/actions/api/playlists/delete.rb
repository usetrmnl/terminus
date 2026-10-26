# frozen_string_literal: true

module Terminus
  module Actions
    module API
      module Playlists
        # The delete action.
        class Delete < Base
          include Deps[repository: "repositories.playlist"]
          include Initable[serializer: Serializers::Playlist]

          using Refines::Actions::Response

          def handle request, response
            id = request.params[:id]
            playlist = repository.with_items.by_pk(id).one

            if repository.delete id
              response.with body: {data: serializer.new(playlist).to_h}.to_json
            else
              response.with_details problem[status: :not_found]
            end
          end
        end
      end
    end
  end
end

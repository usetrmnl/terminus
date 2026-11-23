# frozen_string_literal: true

module Terminus
  module Actions
    module API
      module Playlists
        # The show action.
        class Show < Base
          include Deps[repository: "repositories.playlist"]
          include Initable[serializer: Serializers::Playlist]

          protected

          def handle request, response
            playlist = repository.with_items.by_pk(request.params[:id]).one

            response.body = if playlist
                              {data: serializer.new(playlist).to_h}.to_json
                            else
                              problem[status: :not_found].to_json
                            end
          end
        end
      end
    end
  end
end

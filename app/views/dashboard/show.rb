# frozen_string_literal: true

module Terminus
  module Views
    module Dashboard
      # The show view.
      class Show < View
        include Deps[
          device_relation: "relations.device",
          extension_relation: "relations.extension",
          model_relation: "relations.model",
          playlist_relation: "relations.playlist",
          screen_relation: "relations.screen",
          user_relation: "relations.user"
        ]

        expose :api_uri
        expose :ip_addresses
        expose :firmware
        expose(:devices) { device_relation.count }
        expose(:extensions) { extension_relation.count }
        expose(:models) { model_relation.count }
        expose(:playlists) { playlist_relation.count }
        expose(:screens) { screen_relation.count }
        expose(:users) { user_relation.count }
      end
    end
  end
end

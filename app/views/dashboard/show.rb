# frozen_string_literal: true

module Terminus
  module Views
    module Dashboard
      # The show view.
      class Show < View
        include Deps[
          device_relation: "relations.device",
          extension_relation: "relations.extension",
          firmware_relation: "relations.firmware",
          model_relation: "relations.model",
          playlist_relation: "relations.playlist",
          screen_relation: "relations.screen",
          user_relation: "relations.user"
        ]

        expose :api_uri
        expose :ip_addresses
        expose :firmware
        expose(:device_count) { device_relation.count }
        expose(:extension_count) { extension_relation.count }
        expose(:firmware_count) { firmware_relation.count }
        expose(:model_count) { model_relation.count }
        expose(:playlist_count) { playlist_relation.count }
        expose(:screen_count) { screen_relation.count }
        expose(:user_count) { user_relation.count }
      end
    end
  end
end

# frozen_string_literal: true

module Terminus
  module Aspects
    module Extensions
      # Creates or updates associated screen from Liquid content.
      class ScreenUpserter
        include Deps[
          "aspects.extensions.renderer",
          "aspects.screens.upserter",
          view: "views.extensions.dynamic"
        ]

        def call extension, model_id: nil, device_id: nil
          renderer.call(extension, model_id:, device_id:)
                  .fmap { view.call content: it }
                  .bind do |content|
                    upserter.call model_id:,
                                  device_id:,
                                  content: String.new(content),
                                  **extension.screen_attributes
                  end
        end
      end
    end
  end
end

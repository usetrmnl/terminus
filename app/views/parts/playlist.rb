# frozen_string_literal: true

require "hanami/view"

module Terminus
  module Views
    module Parts
      # The playlist presenter.
      class Playlist < Hanami::View::Part
        include Deps["aspects.screens.faux"]

        def current_screen_pill item, label = "Current Screen"
          return unless current_item_id == item.id

          helpers.tag.div label, class: "bit-pill bit-pill-active"
        end

        def current_screen
          if current_item_id && respond_to?(:current_item)
            current_item.screen
          else
            faux.with id:, uri: "blank.svg"
          end
        end
      end
    end
  end
end

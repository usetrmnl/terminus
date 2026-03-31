# frozen_string_literal: true

module Terminus
  module Aspects
    module Playlists
      # Creates list of screen options for selection within a HTML select element.
      class ScreenOptioner
        include Deps[repository: "repositories.screen"]

        def call prompt: "Select..."
          repository.all.reduce [[prompt, nil]] do |all, screen|
            all.append ["#{screen.label} - #{screen.model.label}", screen.id]
          end
        end
      end
    end
  end
end

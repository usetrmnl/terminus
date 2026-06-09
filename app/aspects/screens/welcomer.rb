# frozen_string_literal: true

module Terminus
  module Aspects
    module Screens
      # Creates welcome screen for new device.
      class Welcomer
        include Deps[creator: "aspects.screens.find_or_creator", view: "views.screens.welcome.new"]

        def call device
          creator.call content: String.new(view.call(device:)),
                       **device.screen_attributes("welcome")
        end
      end
    end
  end
end

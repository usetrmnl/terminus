# frozen_string_literal: true

module Terminus
  module Aspects
    module Screens
      # Creates welcome screen for new device.
      class Welcomer
        include Deps["aspects.screens.creator", view: "views.screens.welcome.new"]

        def call device
          creator.call content: String.new(view.call(device:)),
                       **device.screen_attributes("welcome")
        end
      end
    end
  end
end

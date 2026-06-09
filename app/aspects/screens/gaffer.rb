# frozen_string_literal: true

module Terminus
  module Aspects
    module Screens
      # Creates error with problem details for device.
      class Gaffer
        include Deps["aspects.screens.upserter", view: "views.screens.gaffe.new"]

        def call device, message
          upserter.call content: String.new(view.call(body: message)),
                        **device.screen_attributes("error")
        end
      end
    end
  end
end

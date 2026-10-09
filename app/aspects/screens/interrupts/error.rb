# frozen_string_literal: true

module Terminus
  module Aspects
    module Screens
      module Interrupts
        # Renders device error screen.
        class Error
          include Deps["aspects.screens.upserter", view: "views.screens.interrupts.error.show"]

          def call device, message
            upserter.call content: String.new(view.call(message:)),
                          **device.screen_attributes("error")
          end
        end
      end
    end
  end
end

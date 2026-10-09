# frozen_string_literal: true

require "initable"

module Terminus
  module Aspects
    module Screens
      # Renders immediate screen interrupt for device.
      class Interrupter
        include Deps[
          :i18n,
          "aspects.screens.positioner",
          "aspects.screens.interrupts.error",
          "aspects.screens.interrupts.identify",
          "aspects.screens.interrupts.sleep",
          "aspects.screens.interrupts.wipe"
        ]
        include Initable[manual_events: %w[button EXT0]]

        def call device, event: nil
          manual_events.include?(event) ? interrupt(device, event) : sleep_or_forward(device)
        end

        private

        # rubocop:todo-next Metrics/AbcSize
        # rubocop:todo-next Metrics/MethodLength
        def interrupt device, event
          command = device.command

          case command
            when "identify" then identify.call device
            when "screen_first" then positioner.call(device, event:, direction: :first)
            when "screen_forward" then positioner.call(device, event:, direction: :forward)
            when "screen_backward" then positioner.call(device, event:, direction: :backward)
            when "screen_last" then positioner.call(device, event:, direction: :last)
            when "screen_wipe" then wipe.call device
            else error.call device,
                            i18n.translate("aspects.screens.interrupter.invalid_command", command:)
          end
        end

        def sleep_or_forward device
          if device.asleep?
            sleep.call device
          else
            positioner.call device, direction: :forward
          end
        end
      end
    end
  end
end

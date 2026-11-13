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
        include Initable[
          buttons: %w[button EXT0],
          functions: %w[restart_playlist send_to_me guest_mode]
        ]

        def call device, event: nil
          if buttons.include? event then interrupt device, device.command
          elsif commands.include? event then interrupt device, event
          else sleep_or_forward device
          end
        end

        private

        def interrupt device, command
          case command
            when "identify" then identify.call device
            when "screen_first", "restart_playlist"
              reposition(device, direction: :first, command:)
            when "screen_forward" then reposition(device, direction: :forward, command:)
            when "screen_backward" then reposition(device, direction: :backward, command:)
            when "screen_last" then reposition(device, direction: :last, command:)
            when "screen_wipe" then wipe.call device
            else error.call device,
                            i18n.translate("aspects.screens.interrupter.invalid_command", command:)
          end
        end

        def sleep_or_forward device
          if device.asleep?
            sleep.call device
          else
            reposition device, direction: :forward
          end
        end

        def reposition device, direction:, command: :skip
          positioner.call device, command:, direction:
        end

        def commands
          @commands ||= i18n.translate("devices.shared._fields.commands")
                            .keys
                            .map(&:to_s) + functions
        end
      end
    end
  end
end

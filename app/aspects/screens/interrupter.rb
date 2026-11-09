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

        # rubocop:todo-next Metrics/AbcSize
        # rubocop:todo-next Metrics/MethodLength
        def interrupt device, command
          case command
            when "identify" then identify.call device
            when "screen_first", "restart_playlist"
              positioner.call(device, command:, direction: :first)
            when "screen_forward" then positioner.call(device, command:, direction: :forward)
            when "screen_backward" then positioner.call(device, command:, direction: :backward)
            when "screen_last" then positioner.call(device, command:, direction: :last)
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

        def commands
          @commands ||= i18n.translate("devices.shared._fields.commands")
                            .keys
                            .map(&:to_s) + functions
        end
      end
    end
  end
end

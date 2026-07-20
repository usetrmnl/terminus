# frozen_string_literal: true

module Terminus
  module Views
    module Scopes
      # A customizable popover trigger button.
      class PopoverTriggerButton < Hanami::View::Scope
        def classes = locals.fetch __method__, "bit-popover-trigger"

        def height = locals.fetch __method__, 15

        def icon = locals.fetch __method__, :info

        def icon_uri = "icons/#{icon}.svg"

        def render(path = "shared/popovers/triggers/button") = super

        def target = locals[__method__].then { "popover-#{it}" if it }

        def tip = locals[__method__].then { "tooltip-action-#{it}" if it }

        def width = locals.fetch __method__, 15
      end
    end
  end
end

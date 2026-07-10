# frozen_string_literal: true

module Terminus
  module Views
    module Scopes
      # Provides customized popover content.
      class PopoverScreenContent < Hanami::View::Scope
        def element_id = "popover-screen-#{id}"

        def width = locals.fetch __method__, 800

        def height = locals.fetch __method__, 480

        def render(path = "shared/popovers/content/screen") = super
      end
    end
  end
end

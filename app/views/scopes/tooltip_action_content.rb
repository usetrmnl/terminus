# frozen_string_literal: true

module Terminus
  module Views
    module Scopes
      # Provides customized tooltip content for actions.
      class TooltipActionContent < Hanami::View::Scope
        def element_id = "tooltip-action-#{locals.fetch :id, label.downcase}"

        def classes = locals.fetch __method__, "bit-tooltip-action"

        def render(path = "shared/tooltips/action") = super
      end
    end
  end
end

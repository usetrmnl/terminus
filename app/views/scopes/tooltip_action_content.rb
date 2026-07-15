# frozen_string_literal: true

require "refinements/string"

module Terminus
  module Views
    module Scopes
      # Provides customized tooltip content for actions.
      class TooltipActionContent < Hanami::View::Scope
        using Refinements::String

        def element_id = "tooltip-action-#{locals.fetch :id, label.snakecase}"

        def classes = locals.fetch __method__, "bit-tooltip-action"

        def render(path = "shared/tooltips/action") = super
      end
    end
  end
end

# frozen_string_literal: true

module Terminus
  module Views
    module Scopes
      # Provides customized popover content.
      class PopoverDefaultContent < Hanami::View::Scope
        def element_id = "popover-#{name}"

        def render(path = "shared/popovers/content/default") = super
      end
    end
  end
end

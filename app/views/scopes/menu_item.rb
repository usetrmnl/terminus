# frozen_string_literal: true

module Terminus
  module Views
    module Scopes
      # Renders menu items with automatic active state detection.
      class MenuItem < Hanami::View::Scope
        def classes = locals.fetch __method__, :link

        def data
          locals.fetch(__method__, {}).tap do |attributes|
            return attributes.merge! state: :active if root?

            attributes[:state] = :active if path != "/" && request.path.start_with?(path)
          end
        end

        def root? = request.path == "/" && path == "/"

        def render(path = "shared/menu_item") = super
      end
    end
  end
end

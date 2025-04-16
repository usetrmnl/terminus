# frozen_string_literal: true

module Terminus
  module Views
    module Screens
      module Templates
        # The new view.
        class New < Terminus::View
          # include Deps[builder: "aspects.devices.builder"]

          expose :template
          # expose(:fields) { builder.call }
          expose :errors, default: Dry::Core::EMPTY_HASH
        end
      end
    end
  end
end

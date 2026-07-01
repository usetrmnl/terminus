# frozen_string_literal: true

require "core"

module Terminus
  module Views
    module Designs
      # The new view.
      class New < Terminus::View
        expose :models
        expose :template
        expose :screens, default: Core::EMPTY_ARRAY
        expose :fields, default: Core::EMPTY_HASH
        expose :errors, default: Core::EMPTY_HASH
      end
    end
  end
end

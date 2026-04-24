# frozen_string_literal: true

require "core"

module Terminus
  module Views
    module Models
      # The edit view.
      class Edit < View
        include Deps["aspects.models.palette_optioner"]

        expose :model
        expose(:palette_options) { |model:| palette_optioner.call model }
        expose :fields, default: Core::EMPTY_HASH
        expose :errors, default: Core::EMPTY_HASH
      end
    end
  end
end

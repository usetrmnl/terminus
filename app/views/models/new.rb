# frozen_string_literal: true

module Terminus
  module Views
    module Models
      # The new view.
      class New < View
        include Deps["aspects.models.palette_optioner"]

        expose :model
        expose(:palette_options) { |model: nil| palette_optioner.call model }
        expose :fields, default: Dry::Core::EMPTY_HASH
        expose :errors, default: Dry::Core::EMPTY_HASH
      end
    end
  end
end

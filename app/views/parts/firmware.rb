# frozen_string_literal: true

require "hanami/view"
require "refinements/string"

module Terminus
  module Views
    module Parts
      # The firmware presenter.
      class Firmware < Hanami::View::Part
        include Deps[:routes]

        using Refinements::String

        def first_model_link
          model = models.first

          return "Missing Model" unless model

          models.first.then { helpers.link_to it.label, routes.path(:model, id: it.id) }
        end

        def total_models = models.size.then { %(#{it} #{"model".pluralize "s", it}) }
      end
    end
  end
end

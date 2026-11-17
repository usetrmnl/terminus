# frozen_string_literal: true

require "dry/monads"

module Terminus
  module Aspects
    module Designs
      # Clones an existing design.
      class Cloner
        include Deps["aspects.screens.upserter", repository: "repositories.screen_template"]
        include Dry::Monads[:result]

        def call id, **overrides
          original = repository.find id
          defaults = {label: "#{original.label} Clone", name: "#{original.name}_clone"}

          create original, defaults, overrides
        rescue ROM::SQL::UniqueConstraintError => error
          build_failure error.message
        end

        private

        def create original, defaults, overrides
          merged = {**original.to_h.except(:id, :created_at, :updated_at), **defaults, **overrides}
          template = repository.create merged

          upserter.call(model_id: merged[:model_id], **template.screen_attributes)
                  .fmap { template }
        end

        def build_failure message
          match = message.match(/Key \((?<key>[^)]+)\)/)
          Failure match[:key].to_sym => ["must be unique"]
        end
      end
    end
  end
end

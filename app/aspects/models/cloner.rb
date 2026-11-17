# frozen_string_literal: true

require "dry/monads"

module Terminus
  module Aspects
    module Models
      # Clones an existing model.
      class Cloner
        include Deps[repository: "repositories.model"]
        include Dry::Monads[:result]

        def call id, **overrides
          original = repository.find id

          defaults = {
            label: "#{original.label} Clone",
            name: "#{original.name}_clone",
            kind: "terminus"
          }

          Success create(original, defaults, overrides)
        rescue ROM::SQL::UniqueConstraintError => error
          build_failure error.message
        end

        private

        def create original, defaults, overrides
          repository.create(
            **original.to_h.except(:id, :created_at, :updated_at),
            **defaults,
            **overrides
          )
        end

        def build_failure message
          match = message.match(/Key \((?<key>[^)]+)\)/)
          Failure match[:key].to_sym => ["must be unique"]
        end
      end
    end
  end
end

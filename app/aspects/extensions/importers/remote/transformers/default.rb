# frozen_string_literal: true

require "dry/monads"
require "initable"
require "refinements/string"

module Terminus
  module Aspects
    module Extensions
      module Importers
        module Remote
          module Transformers
            # Transforms (mutates) by adding defaults for initialization.
            class Default
              include Initable[description: "Imported from TRMNL.", unit: "minute"]
              include Dry::Monads[:result]

              using Refinements::String

              def call attributes
                Success attributes.merge!(
                  name: attributes[:label].snakecase,
                  description:,
                  interval: (attributes.fetch(:interval, 60) / 60),
                  unit:
                )
              end
            end
          end
        end
      end
    end
  end
end

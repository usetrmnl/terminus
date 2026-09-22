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
              include Deps[:i18n]
              include Initable[unit: "minute"]
              include Dry::Monads[:result]

              using Refinements::String

              def call attributes
                description = i18n.translate(
                  "aspects.extensions.importers.remote.transformers.default.imported"
                )

                Success attributes.merge!(
                  name: attributes[:label].snakecase.tr("/", "_"),
                  description:,
                  interval: 1,
                  unit: "none"
                )
              end
            end
          end
        end
      end
    end
  end
end

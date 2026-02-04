# frozen_string_literal: true

require "dry/monads"
require "initable"
require "refinements/hash"

module Terminus
  module Aspects
    module Extensions
      module Importers
        module Remote
          module Transformers
            # Transforms (mutates) attributes for initialization.
            class Keys
              include Dry::Monads[:result]

              using Refinements::Hash

              include Initable[
                map: {
                  name: :label,
                  polling_headers: :headers,
                  polling_verb: :verb,
                  polling_url: :uris,
                  polling_body: :body,
                  custom_fields: :fields,
                  refresh_interval: :interval
                },
                deletes: %i[dark_mode]
              ]

              def call attributes
                deletes.each { attributes.delete it }
                attributes.transform_keys! map
                Success attributes
              end
            end
          end
        end
      end
    end
  end
end

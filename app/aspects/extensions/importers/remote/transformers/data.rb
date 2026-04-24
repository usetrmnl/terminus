# frozen_string_literal: true

require "core"
require "dry/monads"
require "initable"

module Terminus
  module Aspects
    module Extensions
      module Importers
        module Remote
          module Transformers
            # Transforms custom field defaults into data defaults.
            class Data
              include Initable[target: :fields, keys: %w[keyname default]]
              include Dry::Monads[:result]

              def call attributes
                data = attributes.fetch(target, Core::EMPTY_HASH)
                                 .each
                                 .with_object({}) do |item, all|
                                   key, value = item.values_at(*keys)
                                   all[key] = value if value
                                 end

                Success attributes.merge!(data:)
              end
            end
          end
        end
      end
    end
  end
end

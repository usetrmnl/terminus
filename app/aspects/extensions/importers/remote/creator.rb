# frozen_string_literal: true

module Terminus
  module Aspects
    module Extensions
      module Importers
        module Remote
          # Creates extension from plugin (recipe).
          class Creator
            include Deps[
              "aspects.extensions.importers.remote.transformer",
              repository: "repositories.extension",
              model_repository: "repositories.model",
              exchange_repository: "repositories.extension_exchange"
            ]

            def call id
              transformer.call(id).fmap do |attributes|
                record = repository.create_with_models attributes, model_ids
                id = record.id

                add_exchanges id, attributes
                repository.find id
              end
            end

            private

            def model_ids
              model_repository.find_by(name: "og_plus").then do |model|
                model ? [model.id] : Dry::Core::EMPTY_ARRAY
              end
            end

            def add_exchanges id, attributes
              headers, verb, pollers, body = attributes.values_at :headers, :verb, :pollers, :body

              pollers.each do |template|
                exchange_repository.create extension_id: id, headers:, verb:, template:, body:
              end
            end
          end
        end
      end
    end
  end
end

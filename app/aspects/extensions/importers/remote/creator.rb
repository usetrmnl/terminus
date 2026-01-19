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
              model_repository: "repositories.model"
            ]

            def call id
              transformer.call(id).fmap do |attributes|
                record = repository.create_with_models attributes, model_ids
                repository.find record.id
              end
            end

            private

            def model_ids
              model_repository.find_by(name: "og_plus").then do |model|
                model ? [model.id] : Dry::Core::EMPTY_ARRAY
              end
            end
          end
        end
      end
    end
  end
end

# frozen_string_literal: true

require "core"
require "dry/monads"

module Terminus
  module Aspects
    module Extensions
      module Importers
        module Remote
          # Creates extension from plugin (recipe).
          class Creator
            include Deps[
              :logger,
              "aspects.extensions.importers.remote.transformer",
              reliquefier: "aspects.extensions.importers.remote.transforms.reliquefier",
              repository: "repositories.extension",
              model_repository: "repositories.model",
              exchange_repository: "repositories.extension_exchange"
            ]

            include Dry::Monads[:result]

            def initialize(problem: Aspects::Errors::Problem, **)
              super(**)
              @problem = problem
            end

            def call id
              transform id
            rescue ROM::SQL::UniqueConstraintError => error
              Failure problem.duplicate(error.message, nil).detail
            end

            private

            attr_reader :problem

            def transform id
              transformer.call(id).fmap do |attributes|
                record = repository.create_with_models attributes, model_ids
                id = record.id

                add_exchanges id, attributes
                repository.find id
              end
            end

            def model_ids
              model_repository.find_by(name: "og_plus").then do |model|
                model ? [model.id] : Core::EMPTY_ARRAY
              end
            end

            def add_exchanges extension_id, attributes
              headers, verb, templates, body = attributes.values_at :poll_headers,
                                                                    :poll_verb,
                                                                    :poll_template,
                                                                    :poll_body

              templates.each do |content|
                template = transform_exchange_template content
                exchange_repository.create extension_id:, headers:, verb:, template:, body:
              end
            end

            def transform_exchange_template content
              case reliquefier.call content
                in Success(content) then content
                in Failure(message)
                  logger.debug { message }
                  Core::EMPTY_STRING
                else
                  logger.error { "Unable to transform exchange template." }
                  Core::EMPTY_STRING
              end
            end
          end
        end
      end
    end
  end
end

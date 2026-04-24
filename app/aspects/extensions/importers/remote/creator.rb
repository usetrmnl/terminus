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
              "aspects.extensions.importers.remote.transformer",
              repository: "repositories.extension",
              model_repository: "repositories.model",
              exchange_repository: "repositories.extension_exchange"
            ]
            include Dry::Monads[:result]

            def initialize(problem_detail: Aspects::ProblemDetail, **)
              super(**)
              @problem_detail = problem_detail
            end

            def call id
              transform id
            rescue ROM::SQL::UniqueConstraintError => error
              Failure problem_detail.duplicate(error.message, nil).detail
            end

            private

            attr_reader :problem_detail

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

            def add_exchanges id, attributes
              headers, verb, templates, body = attributes.values_at :poll_headers,
                                                                    :poll_verb,
                                                                    :poll_template,
                                                                    :poll_body

              templates.each do |template|
                exchange_repository.create extension_id: id, headers:, verb:, template:, body:
              end
            end
          end
        end
      end
    end
  end
end

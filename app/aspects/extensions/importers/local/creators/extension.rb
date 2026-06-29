# frozen_string_literal: true

require "dry/monads"
require "initable"

module Terminus
  module Aspects
    module Extensions
      module Importers
        module Local
          module Creators
            # Creates extension.
            class Extension
              include Deps[:logger, "aspects.jobs.schedule", repository: "repositories.extension"]
              include Initable[error_joiner: proc { Terminus::Aspects::Errors::ResultJoiner }]
              include Dry::Monads[:result]

              def initialize(schema: Schemas::Extension, problem: Aspects::Errors::Problem, **)
                @schema = schema
                @problem = problem
                super(**)
              end

              def call attributes
                schema.call(attributes)
                      .to_monad
                      .alt_map { error_joiner.call "Extension", it }
                      .fmap { create it.to_h }
              rescue ROM::SQL::UniqueConstraintError => error
                Failure problem.duplicate(error.message, nil).detail
              end

              private

              attr_reader :schema, :problem

              def create attributes
                repository.create(attributes).tap do |extension|
                  log extension
                  schedule.upsert(*extension.to_schedule)
                end
              end

              def log extension
                logger.debug do
                  {tags: [{extension_id: extension.id}], message: "Imported extension."}
                end
              end
            end
          end
        end
      end
    end
  end
end

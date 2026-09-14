# frozen_string_literal: true

require "core"
require "dry/monads"

module Terminus
  module Aspects
    module Extensions
      # Deletess an existing extension and job schedule.
      class Deleter
        include Deps["aspects.jobs.schedule", repository: "repositories.extension"]
        include Dry::Monads[:result]

        def call attributes
          id = attributes[:id]
          extension = repository.delete id

          return Failure "Unable to find extension ID: #{id}." unless extension

          schedule.delete extension.screen_name
          Success extension
        end
      end
    end
  end
end

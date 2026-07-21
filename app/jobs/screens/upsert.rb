# auto_register: false
# frozen_string_literal: true

require "core"
require "refinements/hash"

module Terminus
  module Jobs
    module Screens
      # Creates or updates screen.
      class Upsert < Base
        include Deps["aspects.screens.upserter"]
        include Dry::Monads[:result]

        using Refinements::Hash

        sidekiq_options queue: "within_1_minute"

        def perform model_id, attributes = Core::EMPTY_HASH
          case upserter.call(model_id:, **attributes.symbolize_keys)
            in Success(screen) then logger.info { "Enqueued upsert for screen ID: #{screen.id}." }
            in Failure(error) then logger.error { error }
          end
        end
      end
    end
  end
end

# auto_register: false
# frozen_string_literal: true

module Terminus
  module Jobs
    module Attachments
      # Deletes a cached attachment.
      class CacheDelete < Base
        include Deps[:shrine, :logger]
        include Dry::Monads[:result]

        sidekiq_options queue: "within_1_minute"

        def perform id
          shrine.storages[:cache].delete id
          logger.debug { "Deleted cached attachment: #{id}." }
        end
      end
    end
  end
end

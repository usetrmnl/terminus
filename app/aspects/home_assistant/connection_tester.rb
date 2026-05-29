# frozen_string_literal: true

require "dry/monads"

module Terminus
  module Aspects
    module HomeAssistant
      # Verifies connectivity by calling the Home Assistant API root.
      class ConnectionTester
        include Deps["aspects.home_assistant.client"]
        include Dry::Monads[:result]

        def call connection
          client.call(connection, "/api/", require_enabled: false).bind do |payload|
            if payload["message"] == "API running."
              Success payload
            else
              Failure "Unexpected Home Assistant response."
            end
          end
        end
      end
    end
  end
end

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

        using Refinements::Hash

        sidekiq_options queue: "within_1_minute"

        def perform model_id, attributes = Core::EMPTY_HASH
          upserter.call(model_id:, **attributes.symbolize_keys!)
        end
      end
    end
  end
end

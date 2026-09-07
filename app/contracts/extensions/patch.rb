# frozen_string_literal: true

module Terminus
  module Contracts
    module Extensions
      # The contract for extension patches.
      class Patch < Contract
        config.messages.namespace = :extension

        params do
          required(:id).filled :integer
          required(:extension).filled Schemas::Extensions::Patch
          optional(:model_ids).array :integer
          optional(:device_ids).array :integer
        end

        rule extension: :interval, &Rules::Cron
      end
    end
  end
end

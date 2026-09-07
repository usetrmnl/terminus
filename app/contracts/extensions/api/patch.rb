# frozen_string_literal: true

module Terminus
  module Contracts
    module Extensions
      module API
        # The contract for extension patches.
        class Patch < Contract
          params do
            required(:id).filled :integer

            optional(:extension).filled :hash do
              optional(:name).filled :string
              optional(:label).filled :string
              optional(:description).maybe :string
              optional(:mode).filled :string
              optional(:kind).filled :string
              optional(:tags).array :string
              optional(:static_body).maybe :hash
              optional(:template).maybe :string
              optional(:fields).array :hash
              optional(:data).maybe :hash
              optional(:interval).filled :integer
              optional(:unit).filled :string
              optional(:days).array :string
              optional(:last_day_of_month).filled :bool
              optional(:start_at).filled :date_time
            end

            optional(:model_ids).array :integer
            optional(:device_ids).array :integer
          end

          rule extension: :interval, &Rules::Cron
        end
      end
    end
  end
end

# auto_register: false
# frozen_string_literal: true

module Terminus
  module Schemas
    module Extensions
      # Defines extension patch schema.
      Patch = Dry::Schema.Params do
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
    end
  end
end

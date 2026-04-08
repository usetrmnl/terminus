# auto_register: false
# frozen_string_literal: true

module Terminus
  module Schemas
    module Extensions
      # Defines extension upsert schema.
      Upsert = Dry::Schema.Params do
        optional(:model_ids).filled :array
        optional(:device_ids).filled :array
        required(:name).filled :string
        required(:label).filled :string
        required(:description).maybe :string
        optional(:mode).filled :string
        required(:kind).filled :string
        required(:tags).maybe :array
        required(:body).maybe :hash
        required(:template).maybe :string
        required(:fields).maybe :array
        required(:data).maybe :hash
        required(:interval).maybe :integer
        optional(:unit).filled :string
        optional(:days).maybe :array
        required(:last_day_of_month).filled :bool
        required(:start_at).filled :date_time

        after(:value_coercer, &Coercers::LinesToArray.curry[:tags])
        after(:value_coercer, &Coercers::DefaultToFalse.curry[:last_day_of_month])
        after(:value_coercer, &Coercers::DefaultToArray.curry[:days])
        after(:value_coercer, &Coercers::JSONToHash.curry[:body])
        after(:value_coercer, &Coercers::JSONToHash.curry[:fields])
        after(:value_coercer, &Coercers::JSONToHash.curry[:data])
      end
    end
  end
end

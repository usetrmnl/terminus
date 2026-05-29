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
        optional(:home_assistant_source_mode).filled :string
        optional(:home_assistant_entity_ids).maybe :array
        optional(:home_assistant_endpoint_path).maybe :string
        optional(:home_assistant_attribute_map).maybe :hash
        optional(:home_assistant_normalize_urls).filled :bool
        required(:tags).maybe :array
        optional(:body).maybe :hash
        required(:template).maybe :string
        optional(:fields).maybe :array
        optional(:data).maybe :hash
        required(:interval).maybe :integer
        optional(:unit).filled :string
        optional(:days).maybe :array
        required(:last_day_of_month).filled :bool
        required(:start_at).filled :date_time

        after(:value_coercer, &Coercers::LinesToArray.curry[:tags])
        after(:value_coercer, &Coercers::LinesToArray.curry[:home_assistant_entity_ids])
        after(:value_coercer, &Coercers::DefaultToFalse.curry[:last_day_of_month])
        after(:value_coercer, &Coercers::DefaultToTrue.curry[:home_assistant_normalize_urls])
        after(:value_coercer, &Coercers::DefaultToArray.curry[:days])
        after(:value_coercer, &Coercers::JSONToHash.curry[:body])
        after(:value_coercer, &Coercers::JSONToHash.curry[:fields])
        after(:value_coercer, &Coercers::JSONToHash.curry[:data])
        after(:value_coercer, &Coercers::JSONToHash.curry[:home_assistant_attribute_map])
      end
    end
  end
end

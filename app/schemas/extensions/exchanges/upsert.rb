# auto_register: false
# frozen_string_literal: true

module Terminus
  module Schemas
    module Extensions
      module Exchanges
        # Defines extension exchange upsert schema.
        Upsert = Dry::Schema.Params do
          required(:headers).maybe :hash
          required(:verb).filled :string
          required(:template).filled :string
          required(:body).maybe :hash

          after(:value_coercer, &Coercers::JSONToHash.curry[:headers])
          after(:value_coercer, &Coercers::JSONToHash.curry[:body])
        end
      end
    end
  end
end

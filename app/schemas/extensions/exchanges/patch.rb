# auto_register: false
# frozen_string_literal: true

module Terminus
  module Schemas
    module Extensions
      module Exchanges
        # Defines extension exchange patch schema.
        Patch = Dry::Schema.Params do
          optional(:headers).maybe :hash
          optional(:verb).filled :string
          optional(:template).filled :string
          optional(:body).maybe :hash
        end
      end
    end
  end
end

# auto_register: false
# frozen_string_literal: true

module Terminus
  module Aspects
    module Extensions
      module Importers
        module Local
          module Schemas
            # Defines import schema.
            Exchange = Dry::Schema.Params do
              required(:extension_id).filled :integer
              required(:headers).maybe :hash
              required(:verb).filled :string
              required(:template).filled :string
              required(:body).maybe :hash
            end
          end
        end
      end
    end
  end
end

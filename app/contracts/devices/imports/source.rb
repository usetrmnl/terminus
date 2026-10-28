# frozen_string_literal: true

module Terminus
  module Contracts
    module Devices
      module Imports
        # The contract for an device import from source content.
        class Source < Contract
          params do
            required(:devices).filled(:hash) do
              optional(:attachment).maybe Schemas::Attachment
              optional(:uri).maybe :string
            end
          end

          rule :devices do
            case values[:devices].values_at(:attachment, :uri).compact.size
              when 0 then key.failure "attachment or uri must be filled"
              when 2 then key.failure "must provide either attachment or uri but not both"
              else next
            end
          end

          rule(devices: :attachment, &Rules::AttachmentSize)
        end
      end
    end
  end
end

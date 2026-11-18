# frozen_string_literal: true

module Terminus
  module Contracts
    module Models
      # The contract for an model import.
      class Import < Contract
        params do
          required(:model).filled(:hash) { required(:attachment).filled Schemas::Attachment }
        end

        rule(model: :attachment, &Rules::AttachmentSize)
      end
    end
  end
end

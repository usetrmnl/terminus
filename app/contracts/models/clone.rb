# frozen_string_literal: true

module Terminus
  module Contracts
    module Models
      # The contract for model cloning.
      class Clone < Contract
        config.messages.namespace = :model

        params do
          required(:id).filled :integer
          required(:model).filled Schemas::Models::Upsert
        end

        rule model: :mime_type, &Rules::ImageMimeType
      end
    end
  end
end

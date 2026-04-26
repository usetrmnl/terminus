# frozen_string_literal: true

require "dry/monads"

module Terminus
  module Aspects
    module Extensions
      # Exports extension attributes for sharing.
      class Exporter
        include Deps[:settings, exchange_repository: "repositories.extension_exchange"]
        include Dry::Monads[:result]

        def call extension
          exchange_repository.where(extension_id: extension.id)
                             .map(&:export_attributes)
                             .then do |exchanges|
                               Success(
                                 version: settings.git_tag,
                                 **extension.export_attributes,
                                 exchanges:
                               )
                             end
        end
      end
    end
  end
end

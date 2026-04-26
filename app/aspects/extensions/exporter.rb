# frozen_string_literal: true

require "dry/monads"

module Terminus
  module Aspects
    module Extensions
      class Exporter
        include Deps[
          extension_repository: "repositories.extension",
          exchange_repository: "repositories.extension_exchange"
        ]
        include Dry::Monads[:result]

        def call id
          extension = extension_repository.find id

          return Failure "Unable to find extension: #{id}." unless extension

          Success extension.export_attributes
        end
      end
    end
  end
end

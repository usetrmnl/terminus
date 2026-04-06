# frozen_string_literal: true

module Terminus
  module Views
    module Extensions
      # The edit view.
      class Edit < View
        include Deps[
          model_repository: "repositories.model",
          device_repository: "repositories.device",
          exchange_repository: "repositories.extension_exchange"
        ]

        expose(:default_model) { model_repository.find_by name: "og_plus" }
        expose(:models) { model_repository.all.map { [it.label, it.id] } }
        expose(:devices) { device_repository.all.map { [it.label, it.id] } }
        expose(:exchanges) { |extension:| exchange_repository.where extension_id: extension.id }
        expose :extension
        expose :fields, default: Dry::Core::EMPTY_HASH
        expose :errors, default: Dry::Core::EMPTY_HASH
      end
    end
  end
end

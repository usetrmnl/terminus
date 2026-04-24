# frozen_string_literal: true

require "core"

module Terminus
  module Views
    module Extensions
      # The new view.
      class New < View
        include Deps[
          model_repository: "repositories.model",
          device_repository: "repositories.device"
        ]

        expose(:models) { model_repository.all.map { [it.label, it.id] } }
        expose(:devices) { device_repository.all.map { [it.label, it.id] } }
        expose :extension
        expose :fields, default: Core::EMPTY_HASH
        expose :errors, default: Core::EMPTY_HASH
      end
    end
  end
end

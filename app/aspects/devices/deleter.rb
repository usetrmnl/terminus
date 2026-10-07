# frozen_string_literal: true

module Terminus
  module Aspects
    module Devices
      # Deletes device and associated screens.
      class Deleter
        include Deps[repository: "repositories.device", screen_repository: "repositories.screen"]

        def call id, kinds: %w[error welcome].freeze
          screen_repository.where(device_id: id, kind: kinds)
                           .each { screen_repository.delete it.id }
          repository.delete id
        end
      end
    end
  end
end

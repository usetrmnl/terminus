# auto_register: false
# frozen_string_literal: true

module Terminus
  module Jobs
    module Synchronizers
      # Synchronizes server hosted sensor data.
      class Sensor < Base
        include Deps["aspects.devices.sensors.synchronizer"]

        sidekiq_options queue: "within_1_minute"

        def perform = synchronizer.call
      end
    end
  end
end

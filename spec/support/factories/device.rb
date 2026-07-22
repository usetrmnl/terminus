# frozen_string_literal: true

Factory.define :device, relation: :device do |factory|
  factory.association :model

  factory.api_key { SecureRandom.alphanumeric 30 }
  factory.battery_charge 0
  factory.battery_voltage 3.0
  factory.display_compatibility false
  factory.display_profile "default"
  factory.firmware_update true
  factory.firmware_version "1.2.3"
  factory.label "Test"
  factory.mac_address "A1:B2:C3:D4:E5:F6"
  factory.command "none"
  factory.touch_bar "tap"
  factory.wifi_band 0
  factory.wifi_signal(-44)
end

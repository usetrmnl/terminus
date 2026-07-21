# frozen_string_literal: true

Factory.define :device_log, relation: :device_log do |factory|
  factory.association :device
  factory.sequence(:external_id) { it }
  factory.message "Danger!"
  factory.source_path "src/test.cpp"
  factory.source_line 13
  factory.retry 3
  factory.wifi_signal(-33)
  factory.wifi_status "connected"
  factory.refresh_rate 50
  factory.sleep_duration 25
  factory.firmware_version "1.2.3"
  factory.command "none"
  factory.wake_reason "timer"
  factory.battery_voltage 4.75
  factory.free_heap_size 150000
end

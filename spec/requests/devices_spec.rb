# frozen_string_literal: true

require "hanami_helper"

RSpec.describe "/api/devices", :db do
  include_context "with JWT"

  let(:device) { Factory[:device, model_id: model.id, playlist_id: playlist.id] }
  let(:model) { Factory[:model] }
  let(:playlist) { Factory[:playlist] }

  let :attributes do
    {
      model_id: model.id,
      playlist_id: playlist.id,
      label: "Test",
      mac_address: "A1:B2:C3:D4:E5:F6",
      api_key: "abc123",
      refresh_rate: 100,
      image_cached: "on",
      image_timeout: 5,
      display_compatibility: "on",
      display_profile: "default",
      firmware_profile: "on",
      firmware_update: "on",
      firmware_version: "1.2.3",
      charging: "on",
      battery_charge: 85.0,
      battery_voltage: 3.5,
      wifi_band: 2.4,
      wifi_signal: -75,
      width: 800,
      height: 480,
      command: "identify",
      touch_bar: "swipe",
      wake_duration: 123,
      wake_reason: "Awoken from test.",
      sleep_start_at: "18:00:00+0000",
      sleep_stop_at: "06:00:00+0000",
      synced_at: "2026-06-01T01:02:03+00:00"
    }
  end

  it "answers devices" do
    device

    get routes.path(:api_devices),
        {},
        "HTTP_AUTHORIZATION" => access_token,
        "CONTENT_TYPE" => "application/json"

    expect(json_payload).to match(
      data: [
        hash_including(
          id: device.id,
          model_id: model.id,
          playlist_id: playlist.id,
          label: "Test",
          mac_address: "A1:B2:C3:D4:E5:F6",
          api_key: match_device_api_key,
          refresh_rate: 900,
          image_cached: false,
          image_timeout: 0,
          display_compatibility: false,
          display_profile: "default",
          firmware_profile: false,
          firmware_update: true,
          firmware_version: "1.2.3",
          charging: false,
          battery_charge: 0.0,
          battery_voltage: 3.0,
          wifi_band: 0.0,
          wifi_signal: -44,
          width: 0,
          height: 0,
          touch_bar: "tap",
          wake_duration: 0,
          wake_reason: nil,
          sleep_start_at: nil,
          sleep_stop_at: nil,
          created_at: match_rfc_3339,
          updated_at: match_rfc_3339,
          synced_at: nil
        )
      ]
    )
  end

  it "answers empty array when devices don't exist" do
    get routes.path(:api_devices),
        {},
        "HTTP_AUTHORIZATION" => access_token,
        "CONTENT_TYPE" => "application/json"

    expect(json_payload).to eq(data: [])
  end

  it "answers device when it exists" do
    get routes.path(:api_device, id: device.id),
        {},
        "HTTP_AUTHORIZATION" => access_token,
        "CONTENT_TYPE" => "application/json"

    expect(json_payload).to match(
      data: {
        id: device.id,
        model_id: model.id,
        playlist_id: playlist.id,
        label: "Test",
        mac_address: "A1:B2:C3:D4:E5:F6",
        api_key: match_device_api_key,
        refresh_rate: 900,
        image_cached: false,
        image_timeout: 0,
        firmware_profile: false,
        firmware_update: true,
        firmware_version: "1.2.3",
        battery_charge: 0,
        battery_voltage: 3.0,
        charging: false,
        wifi_band: 0.0,
        wifi_signal: -44,
        width: 0,
        height: 0,
        display_compatibility: false,
        display_profile: "default",
        wake_duration: 0,
        wake_reason: nil,
        command: "none",
        touch_bar: "tap",
        sleep_start_at: nil,
        sleep_stop_at: nil,
        created_at: match_rfc_3339,
        updated_at: match_rfc_3339,
        synced_at: nil
      }
    )
  end

  it "answers not found error when device doesn't exist" do
    get routes.path(:api_device, id: 666),
        {},
        "HTTP_AUTHORIZATION" => access_token,
        "CONTENT_TYPE" => "application/json"

    expect(json_payload).to eq(Petail[status: :not_found].to_h)
  end

  it "creates device with valid attributes" do
    post routes.path(:api_devices),
         {device: attributes}.to_json,
         "HTTP_AUTHORIZATION" => access_token,
         "CONTENT_TYPE" => "application/json"

    expect(json_payload).to match(
      data: hash_including(
        id: kind_of(Integer),
        model_id: model.id,
        playlist_id: kind_of(Integer),
        label: "Test",
        mac_address: "A1:B2:C3:D4:E5:F6",
        api_key: "abc123",
        refresh_rate: 100,
        image_cached: true,
        image_timeout: 5,
        display_compatibility: true,
        display_profile: "default",
        firmware_profile: true,
        firmware_update: true,
        firmware_version: "1.2.3",
        charging: true,
        battery_charge: 85.0,
        battery_voltage: 3.5,
        wifi_band: 2.4,
        wifi_signal: -75,
        width: 800,
        height: 480,
        command: "identify",
        touch_bar: "swipe",
        wake_duration: 123,
        wake_reason: "Awoken from test.",
        sleep_start_at: "18:00:00",
        sleep_stop_at: "06:00:00",
        created_at: match_rfc_3339,
        updated_at: match_rfc_3339,
        synced_at: match_rfc_3339
      )
    )
  end

  it "creates device with valid (required only) attributes" do
    attributes = {
      model_id: model.id,
      playlist_id: nil,
      label: "Test",
      mac_address: "A1:B2:C3:D4:E5:F6",
      api_key: "abc123"
    }

    post routes.path(:api_devices),
         {device: attributes}.to_json,
         "HTTP_AUTHORIZATION" => access_token,
         "CONTENT_TYPE" => "application/json"

    expect(json_payload).to match(
      data: hash_including(
        id: kind_of(Integer),
        model_id: model.id,
        playlist_id: kind_of(Integer),
        label: "Test",
        mac_address: "A1:B2:C3:D4:E5:F6",
        api_key: "abc123",
        refresh_rate: 900,
        image_cached: false,
        image_timeout: 0,
        display_compatibility: false,
        display_profile: "default",
        firmware_profile: false,
        firmware_update: false,
        firmware_version: nil,
        charging: false,
        battery_charge: 0,
        battery_voltage: 0,
        wifi_band: 0,
        wifi_signal: 0,
        width: 0,
        height: 0,
        touch_bar: "tap",
        wake_duration: 0,
        wake_reason: nil,
        sleep_start_at: nil,
        sleep_stop_at: nil,
        created_at: match_rfc_3339,
        updated_at: match_rfc_3339,
        synced_at: nil
      )
    )
  end

  it "answers problem details when creation fails" do
    attributes.delete :model_id

    post routes.path(:api_devices),
         {device: attributes}.to_json,
         "HTTP_AUTHORIZATION" => access_token,
         "CONTENT_TYPE" => "application/json"

    problem = Petail[
      type: "/problem_details#device_payload",
      status: :unprocessable_content,
      detail: "Validation failed.",
      instance: "/api/devices",
      extensions: {
        errors: {
          device: {
            model_id: ["is missing"]
          }
        }
      }
    ]

    expect(json_payload).to match(problem.to_h)
  end

  it "answers problem details for invalid model" do
    attributes[:model_id] = 666

    post routes.path(:api_devices),
         {device: attributes}.to_json,
         "HTTP_AUTHORIZATION" => access_token,
         "CONTENT_TYPE" => "application/json"

    problem = Petail[
      type: "/problem_details#device_payload",
      status: :not_found,
      detail: %(Key (model_id)=(666) is not present in table "model".),
      instance: "/api/devices"
    ]

    expect(json_payload).to match(problem.to_h)
  end

  it "patches device when valid" do
    patch routes.path(:api_device, id: device.id),
          {device: {label: "Test Patch"}}.to_json,
          "HTTP_AUTHORIZATION" => access_token,
          "CONTENT_TYPE" => "application/json"

    expect(json_payload.dig(:data, :label)).to eq("Test Patch")
  end

  it "answers problem details with empty attributes" do
    patch routes.path(:api_device, id: device.id),
          {device: {}}.to_json,
          "HTTP_AUTHORIZATION" => access_token,
          "CONTENT_TYPE" => "application/json"

    problem = Petail[
      type: "/problem_details#device_payload",
      status: :unprocessable_content,
      detail: "Validation failed.",
      instance: "/api/devices",
      extensions: {
        errors: {
          device: ["must be filled"]
        }
      }
    ]

    expect(json_payload).to match(problem.to_h)
  end

  it "answers error when patch fails" do
    patch routes.path(:api_device, id: device.id),
          {device: {sleep_stop_at: "10:10:10"}}.to_json,
          "HTTP_AUTHORIZATION" => access_token,
          "CONTENT_TYPE" => "application/json"

    problem = Petail[
      type: "/problem_details#device_payload",
      status: :unprocessable_content,
      detail: "Validation failed.",
      instance: "/api/devices",
      extensions: {
        errors: {
          device: {
            sleep_start_at: ["must be filled"],
            sleep_stop_at: ["must have corresponding start time"]
          }
        }
      }
    ]

    expect(json_payload).to match(problem.to_h)
  end

  it "deletes existing record" do
    delete routes.path(:api_device, id: device.id),
           {},
           "HTTP_AUTHORIZATION" => access_token,
           "CONTENT_TYPE" => "application/json"

    expect(json_payload).to match(
      data: {
        id: device.id,
        model_id: model.id,
        playlist_id: playlist.id,
        label: "Test",
        mac_address: "A1:B2:C3:D4:E5:F6",
        api_key: match_device_api_key,
        refresh_rate: 900,
        image_cached: false,
        image_timeout: 0,
        display_compatibility: false,
        display_profile: "default",
        firmware_profile: false,
        firmware_update: true,
        firmware_version: "1.2.3",
        charging: false,
        battery_charge: 0,
        battery_voltage: 3.0,
        wifi_band: 0.0,
        wifi_signal: -44,
        width: 0,
        height: 0,
        command: "none",
        touch_bar: "tap",
        wake_duration: 0,
        wake_reason: nil,
        sleep_start_at: nil,
        sleep_stop_at: nil,
        created_at: match_rfc_3339,
        updated_at: match_rfc_3339,
        synced_at: nil
      }
    )
  end

  it "answers empty payload with invalid ID" do
    delete routes.path(:api_device, id: 666),
           {},
           "HTTP_AUTHORIZATION" => access_token,
           "CONTENT_TYPE" => "application/json"

    expect(json_payload).to match(data: {})
  end
end

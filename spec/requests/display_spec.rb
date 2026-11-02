# frozen_string_literal: true

require "hanami_helper"

RSpec.describe "/api/display", :db do
  include_context "with firmware headers"

  let(:device) { provisioner.call(model_id: model.id, api_key:, firmware_version: "1.2.3").value! }
  let(:api_key) { firmware_headers.fetch "HTTP_ACCESS_TOKEN" }
  let(:provisioner) { Terminus::Aspects::Devices::Provisioner.new }
  let(:model) { Factory[:model] }

  before do
    firmware = Factory[:firmware, :with_attachment, version: "1.2.3"]
    Factory[:firmware_model, firmware_id: firmware.id, model_id: model.id]
  end

  it "answers payload with all atttributes" do
    device
    get routes.path(:api_display), {}, **firmware_headers

    expect(json_payload).to match(
      filename: /welcome_#{device.id}-\d{10}/,
      firmware_url: "memory://abc123.bin",
      firmware_version: "1.2.3",
      image_url: match_shrine_uri(extension: :png),
      image_url_timeout: 0,
      maximum_compatibility: false,
      refresh_rate: 900,
      reset_firmware: false,
      special_function: "none",
      temperature_profile: "default",
      touchbar_mode: "tap",
      update_firmware: false
    )
  end

  it "answers payload with custom device attribute" do
    provisioner.call(model_id: model.id, api_key:, refresh_rate: 20).value!
    get routes.path(:api_display), {}, **firmware_headers

    expect(json_payload).to include(refresh_rate: 20)
  end

  it "answers firmware update when device update is enabled and versions don't match" do
    firmware = Factory[:firmware, :with_attachment, version: "3.2.1"]
    Factory[:firmware_model, firmware_id: firmware.id, model_id: model.id]
    provisioner.call(model_id: model.id, api_key:, firmware_update: true).value!

    get routes.path(:api_display), {}, **firmware_headers

    expect(json_payload).to include(update_firmware: true)
  end

  it "removes firmware URI when firmware doesn't exist" do
    Terminus::Repositories::Firmware.new.delete_all
    device
    get routes.path(:api_display), {}, **firmware_headers

    expect(json_payload).to match(
      filename: /welcome_#{device.id}-\d{10}/,
      firmware_url: nil,
      firmware_version: "1.2.3",
      image_url: match_shrine_uri(extension: :png),
      image_url_timeout: 0,
      maximum_compatibility: false,
      refresh_rate: 900,
      reset_firmware: false,
      special_function: "none",
      temperature_profile: "default",
      touchbar_mode: "tap",
      update_firmware: false
    )
  end

  context "with invalid/missing headers" do
    before { get routes.path(:api_display) }

    it "answers not found problem details" do
      problem = RFC::API::Problem[
        type: "/problem_details#api_key",
        status: :not_found,
        detail: "Invalid API key.",
        instance: "/api/display"
      ]

      expect(json_payload).to eq(problem.to_h)
    end
  end

  context "with no device" do
    before { get routes.path(:api_display), {}, **firmware_headers }

    it "answers problem details" do
      problem = RFC::API::Problem[
        type: "/problem_details#api_key",
        status: :not_found,
        detail: "Invalid API key.",
        instance: "/api/display"
      ]

      expect(json_payload).to eq(problem.to_h)
    end

    it "answers content type and status" do
      expect(last_response).to have_attributes(
        content_type: "application/problem+json; charset=utf-8",
        status: 404
      )
    end
  end

  context "with any error" do
    let(:device) { Factory[:device, api_key:, firmware_version: "1.2.3"] }

    before do
      device
      get routes.path(:api_display), {}, **firmware_headers
    end

    it "answers error image" do
      expect(json_payload).to match(
        filename: "#{device.screen_name :error}.png",
        firmware_url: nil,
        firmware_version: "1.2.3",
        image_url: match_shrine_uri(extension: :png),
        image_url_timeout: 0,
        maximum_compatibility: false,
        refresh_rate: 900,
        reset_firmware: false,
        special_function: "none",
        temperature_profile: "default",
        touchbar_mode: "tap",
        update_firmware: false
      )
    end

    it "answers content type and OK status" do
      expect(last_response).to have_attributes(
        content_type: "application/json; charset=utf-8",
        status: 200
      )
    end
  end
end

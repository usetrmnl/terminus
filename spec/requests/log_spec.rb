# frozen_string_literal: true

require "hanami_helper"

RSpec.describe "/api/log", :db do
  let(:device) { Factory[:device] }
  let(:repository) { Terminus::Repositories::DeviceLog.new }

  let :headers do
    {
      "CONTENT_TYPE" => "application/json",
      "HTTP_ID" => device.mac_address,
      "HTTP_ACCESS_TOKEN" => device.api_key
    }
  end

  let :payload do
    {
      logs: [
        {
          battery_voltage: 4.772,
          created_at: 1742000523,
          firmware_version: "1.2.3",
          free_heap_size: 210000,
          id: 1,
          level: "debug",
          max_alloc_size: 300000,
          message: "Danger!",
          refresh_rate: 500,
          retry: 2,
          sleep_duration: 50,
          source_line: 5,
          source_path: "src/bl.cpp",
          special_function: "none",
          wake_reason: "timer",
          wifi_signal: -54,
          wifi_status: "connected"
        }
      ]
    }
  end

  context "with valid payload" do
    before { post routes.path(:api_log), payload.to_json, **headers }

    it "create record" do
      expect(repository.all.first).to have_attributes(
        battery_voltage: 4.772,
        created_at: Time.utc(2025, 3, 15, 1, 2, 3),
        device_id: device.id,
        external_id: 1,
        firmware_version: "1.2.3",
        free_heap_size: 210000,
        level: "debug",
        max_alloc_size: 300000,
        message: "Danger!",
        refresh_rate: 500,
        retry: 2,
        sleep_duration: 50,
        source_line: 5,
        source_path: "src/bl.cpp",
        special_function: "none",
        wake_reason: "timer",
        wifi_signal: -54,
        wifi_status: "connected"
      )
    end

    it "answers success (no content)" do
      expect(last_response.status).to eq(204)
    end
  end

  context "with invalid ID header" do
    before do
      headers.delete "HTTP_ID"
      post routes.path(:api_log), payload.to_json, **headers
    end

    it "answers problem details" do
      problem = Petail[
        type: "/problem_details#device_id",
        status: 404,
        title: "Not Found",
        detail: "Invalid device ID.",
        instance: "/api/log"
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

  context "with invalid payload" do
    before { post routes.path(:api_log), {logs: []}.to_json, **headers }

    it "doesn't create record" do
      expect(repository.all).to eq([])
    end

    it "answers problem details" do
      problem = Petail[
        type: "/problem_details#log_payload",
        status: :unprocessable_content,
        detail: "Validation failed due to incorrect or invalid payload.",
        instance: "/api/log",
        extensions: {errors: {logs: ["must be filled"]}}
      ]

      expect(json_payload).to eq(problem.to_h)
    end

    it "answers content type and status" do
      expect(last_response).to have_attributes(
        content_type: "application/problem+json; charset=utf-8",
        status: 422
      )
    end
  end
end

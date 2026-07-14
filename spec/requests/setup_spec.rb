# frozen_string_literal: true

require "hanami_helper"

RSpec.describe "/api/setup", :db do
  let(:device) { Factory[:device, model_id: model.id] }
  let(:model) { Factory[:model, name: "og_plus"] }

  let :headers do
    {"HTTP_FW_VERSION" => "1.2.3", "HTTP_ID" => "A1:B2:C3:D4:E5:F6", "HTTP_MODEL" => "og"}
  end

  it "answers new device when missing" do
    model
    get routes.path(:api_setup), {}, **headers

    expect(json_payload).to match(
      api_key: match_device_api_key,
      image_url: %(#{settings.api_uri}/assets/setup.bmp),
      message: "Welcome to Terminus!",
      status: 200
    )
  end

  it "answers existing device for MAC address" do
    headers["HTTP_ID"] = device.mac_address
    get routes.path(:api_setup), {}, **headers

    expect(json_payload).to match(
      api_key: device.api_key,
      image_url: %(#{settings.api_uri}/assets/setup.bmp),
      message: "Welcome to Terminus!",
      status: 200
    )
  end

  it "answers problem details when model for device doesn't exist" do
    get routes.path(:api_setup), {}, **headers

    problem = Petail[
      type: "/problem_details#device_setup",
      status: :not_found,
      detail: %(Null value in column "model_id" of relation "device" violates not-null constraint.),
      instance: "/api/setup"
    ]

    expect(json_payload).to eq(problem.to_h)
  end

  it "answers problem details when firmware version header is invalid" do
    headers["HTTP_FW_VERSION"] = "bogus"
    get routes.path(:api_setup), {}, **headers

    problem = Petail[
      type: "/problem_details#device_setup",
      status: :unprocessable_content,
      detail: "Invalid request headers.",
      instance: "/api/setup",
      extensions: {
        errors: {
          HTTP_FW_VERSION: ["is in invalid format"]
        }
      }
    ]

    expect(json_payload).to eq(problem.to_h)
  end

  it "answers problem details when device ID header is invalid" do
    headers["HTTP_ID"] = "bogus"
    get routes.path(:api_setup), {}, **headers

    problem = Petail[
      type: "/problem_details#device_setup",
      status: :unprocessable_content,
      detail: "Invalid request headers.",
      instance: "/api/setup",
      extensions: {
        errors: {
          HTTP_ID: ["is in invalid format"]
        }
      }
    ]

    expect(json_payload).to eq(problem.to_h)
  end
end

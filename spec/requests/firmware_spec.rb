# frozen_string_literal: true

require "hanami_helper"

RSpec.describe "/api/firmware", :db do
  include_context "with JWT"

  let(:firmware) { Factory[:firmware, :with_attachment, **attributes] }
  let(:uri) { "https://trmnl-fw.s3.us-east-2.amazonaws.com/trmnl_og/FW1.8.5.bin" }

  let :attributes do
    {
      version: "0.0.0",
      kind: "test"
    }
  end

  include_context "with temporary directory"

  it "answers firmwares" do
    firmware

    get routes.path(:api_firmwares),
        {},
        "HTTP_AUTHORIZATION" => access_token,
        "CONTENT_TYPE" => "application/json"

    expect(json_payload).to match(
      data: [
        {
          id: firmware.id,
          version: "0.0.0",
          kind: "test",
          file_name: "0.0.0.bin",
          uri: "memory://abc123.bin",
          mime_type: "application/octet-stream",
          size: 4,
          created_at: match_rfc_3339,
          updated_at: match_rfc_3339
        }
      ]
    )
  end

  it "answers empty array when no records exist" do
    get routes.path(:api_firmwares),
        {},
        "HTTP_AUTHORIZATION" => access_token,
        "CONTENT_TYPE" => "application/json"

    expect(json_payload).to eq(data: [])
  end

  it "answers existing firmware" do
    get routes.path(:api_firmware, id: firmware.id),
        {},
        "HTTP_AUTHORIZATION" => access_token,
        "CONTENT_TYPE" => "application/json"

    expect(json_payload).to match(
      data: {
        id: firmware.id,
        version: "0.0.0",
        kind: "test",
        file_name: "0.0.0.bin",
        uri: "memory://abc123.bin",
        mime_type: "application/octet-stream",
        size: 4,
        created_at: match_rfc_3339,
        updated_at: match_rfc_3339
      }
    )
  end

  it "answers not found error with invalid ID" do
    get routes.path(:api_firmware, id: 13),
        {},
        "HTTP_AUTHORIZATION" => access_token,
        "CONTENT_TYPE" => "application/json"

    expect(json_payload).to eq(Petail[status: :not_found].to_h)
  end

  it "creates firmware when valid" do
    post routes.path(:api_firmwares),
         {firmware: {uri:, **attributes}}.to_json,
         "HTTP_AUTHORIZATION" => access_token,
         "CONTENT_TYPE" => "application/json"

    expect(json_payload).to match(
      data: {
        id: kind_of(Integer),
        version: "0.0.0",
        kind: "test",
        file_name: "0.0.0.bin",
        uri: %r(memory://\h{32}\.bin),
        mime_type: "application/octet-stream",
        size: kind_of(Integer),
        created_at: match_rfc_3339,
        updated_at: match_rfc_3339
      }
    )
  end

  it "answers error with invalid URI for POST" do
    post routes.path(:api_firmwares),
         {firmware: {uri: "bogus", **attributes}}.to_json,
         "HTTP_AUTHORIZATION" => access_token,
         "CONTENT_TYPE" => "application/json"

    problem = Petail[
      type: "/problem_details#firmware_payload",
      status: :unprocessable_content,
      detail: "Invalid URI: bogus.",
      instance: "/api/firmware"
    ]

    expect(json_payload).to match(problem.to_h)
  end

  it "answers error with missing URI" do
    post routes.path(:api_firmwares),
         {firmware: attributes}.to_json,
         "HTTP_AUTHORIZATION" => access_token,
         "CONTENT_TYPE" => "application/json"

    problem = Petail[
      type: "/problem_details#firmware_payload",
      status: :unprocessable_content,
      detail: "Validation failed.",
      instance: "/api/firmware",
      extensions: {
        errors: {
          firmware: {
            uri: ["is missing"]
          }
        }
      }
    ]

    expect(json_payload).to match(problem.to_h)
  end

  it "patches firmware when valid with attachment" do
    patch routes.path(:api_firmware, id: firmware.id),
          {firmware: {uri:, **attributes}}.to_json,
          "HTTP_AUTHORIZATION" => access_token,
          "CONTENT_TYPE" => "application/json"

    expect(json_payload).to match(
      data: {
        id: firmware.id,
        version: "0.0.0",
        kind: "test",
        file_name: "0.0.0.bin",
        uri: %r(memory://\h{32}\.bin),
        mime_type: "application/octet-stream",
        size: kind_of(Integer),
        created_at: match_rfc_3339,
        updated_at: match_rfc_3339
      }
    )
  end

  it "patches firmware when valid without attachment" do
    patch routes.path(:api_firmware, id: firmware.id),
          {firmware: attributes}.to_json,
          "HTTP_AUTHORIZATION" => access_token,
          "CONTENT_TYPE" => "application/json"

    expect(json_payload).to match(
      data: {
        id: firmware.id,
        version: "0.0.0",
        kind: "test",
        file_name: "0.0.0.bin",
        uri: "memory://abc123.bin",
        mime_type: "application/octet-stream",
        size: 4,
        created_at: match_rfc_3339,
        updated_at: match_rfc_3339
      }
    )
  end

  it "answers error with invalid URI for PATCH" do
    patch routes.path(:api_firmware, id: firmware.id),
          {firmware: {uri: "bogus"}}.to_json,
          "HTTP_AUTHORIZATION" => access_token,
          "CONTENT_TYPE" => "application/json"

    problem = Petail[
      type: "/problem_details#firmware_payload",
      status: :unprocessable_content,
      detail: "Invalid URI: bogus.",
      instance: "/api/firmware"
    ]

    expect(json_payload).to match(problem.to_h)
  end

  it "answers error with missing attributes" do
    patch routes.path(:api_firmware, id: firmware.id),
          {firmware: {}}.to_json,
          "HTTP_AUTHORIZATION" => access_token,
          "CONTENT_TYPE" => "application/json"

    problem = Petail[
      type: "/problem_details#firmware_payload",
      status: :unprocessable_content,
      detail: "Validation failed.",
      instance: "/api/firmware",
      extensions: {
        errors: {
          firmware: ["must be filled"]
        }
      }
    ]

    expect(json_payload).to match(problem.to_h)
  end

  it "deletes existing record" do
    delete routes.path(:api_firmware, id: firmware.id),
           {},
           "HTTP_AUTHORIZATION" => access_token,
           "CONTENT_TYPE" => "application/json"

    expect(json_payload).to match(
      data: {
        id: firmware.id,
        version: "0.0.0",
        kind: "test",
        file_name: "0.0.0.bin",
        uri: "memory://abc123.bin",
        mime_type: "application/octet-stream",
        size: 4,
        created_at: match_rfc_3339,
        updated_at: match_rfc_3339
      }
    )
  end

  it "answers error with invalid ID" do
    delete routes.path(:api_firmware, id: 666),
           {},
           "HTTP_AUTHORIZATION" => access_token,
           "CONTENT_TYPE" => "application/json"

    expect(json_payload).to match(status: 404, title: "Not Found", type: "about:blank")
  end
end

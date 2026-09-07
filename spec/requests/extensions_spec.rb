# frozen_string_literal: true

require "hanami_helper"

RSpec.describe "/api/extensions", :db do
  include_context "with JWT"

  let(:extension) { Factory[:extension] }

  it "answers records when extensions exist" do
    extension

    get routes.path(:api_extensions),
        {},
        "HTTP_AUTHORIZATION" => access_token,
        "CONTENT_TYPE" => "application/json"

    expect(json_payload).to match(
      data: [
        {
          id: extension.id,
          label: extension.label,
          name: extension.name,
          description: nil,
          kind: "poll",
          mode: "text",
          tags: [],
          static_body: {},
          fields: [],
          template: "<h1>{{source_1.label}}</h1>",
          data: {},
          interval: 1,
          unit: "none",
          days: [],
          last_day_of_month: false,
          start_at: match_rfc_3339,
          created_at: match_rfc_3339,
          updated_at: match_rfc_3339
        }
      ]
    )
  end

  it "answers empty array when extensions don't exist" do
    get routes.path(:api_extensions),
        {},
        "HTTP_AUTHORIZATION" => access_token,
        "CONTENT_TYPE" => "application/json"

    expect(json_payload).to eq(data: [])
  end

  it "answers existing extension" do
    get routes.path(:api_extension, id: extension.id),
        {},
        "HTTP_AUTHORIZATION" => access_token,
        "CONTENT_TYPE" => "application/json"

    expect(json_payload).to match(
      data: {
        id: extension.id,
        label: extension.label,
        name: extension.name,
        description: nil,
        kind: "poll",
        mode: "text",
        tags: [],
        static_body: {},
        fields: [],
        template: "<h1>{{source_1.label}}</h1>",
        data: {},
        interval: 1,
        unit: "none",
        days: [],
        last_day_of_month: false,
        start_at: match_rfc_3339,
        created_at: match_rfc_3339,
        updated_at: match_rfc_3339
      }
    )
  end

  it "answers not found error with invalid ID" do
    get routes.path(:api_extension, id: 666),
        {},
        "HTTP_AUTHORIZATION" => access_token,
        "CONTENT_TYPE" => "application/json"

    expect(json_payload).to eq(RFC::API::Problem[status: :not_found].to_h)
  end

  it "creates extension" do
    post routes.path(:api_extensions),
         {
           extension: {
             label: "Test",
             name: "test",
             description: "A test.",
             kind: "static",
             mode: "text",
             tags: [],
             static_body: {name: "test"},
             fields: [],
             template: "<h1>{{source_1.label}}</h1>",
             data: {},
             interval: 1,
             unit: "none",
             days: [],
             last_day_of_month: false,
             start_at: Time.now
           }
         }.to_json,
         "HTTP_AUTHORIZATION" => access_token,
         "CONTENT_TYPE" => "application/json"

    expect(json_payload).to match(
      data: {
        id: kind_of(Integer),
        label: "Test",
        name: "test",
        description: "A test.",
        kind: "static",
        mode: "text",
        tags: [],
        static_body: {name: "test"},
        fields: [],
        template: "<h1>{{source_1.label}}</h1>",
        data: {},
        interval: 1,
        unit: "none",
        days: [],
        last_day_of_month: false,
        start_at: match_rfc_3339,
        created_at: match_rfc_3339,
        updated_at: match_rfc_3339
      }
    )
  end

  context "without body" do
    before do
      post routes.path(:api_extensions),
           {},
           "HTTP_AUTHORIZATION" => access_token,
           "CONTENT_TYPE" => "application/json"
    end

    it "answers problem details" do
      problem = RFC::API::Problem[
        type: "/problem_details#extension_payload",
        status: :unprocessable_content,
        detail: "Validation failed.",
        instance: "/api/extensions",
        extensions: {errors: {extension: ["is missing"]}}
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

  it "patches template" do
    patch routes.path(:api_extension, id: extension.id),
          {extension: {template: "<h1>Test</h1>"}}.to_json,
          "HTTP_AUTHORIZATION" => access_token,
          "CONTENT_TYPE" => "application/json"

    expect(json_payload).to match(
      data: {
        id: extension.id,
        label: extension.label,
        name: extension.name,
        description: nil,
        kind: "poll",
        mode: "text",
        tags: [],
        static_body: {},
        fields: [],
        template: "<h1>Test</h1>",
        data: {},
        interval: 1,
        unit: "none",
        days: [],
        last_day_of_month: false,
        start_at: match_rfc_3339,
        created_at: match_rfc_3339,
        updated_at: match_rfc_3339
      }
    )
  end

  it "answers problem details for invalid value" do
    patch routes.path(:api_extension, id: extension.id),
          {extension: {name: 13}}.to_json,
          "HTTP_AUTHORIZATION" => access_token,
          "CONTENT_TYPE" => "application/json"

    problem = RFC::API::Problem[
      type: "/problem_details#extension_payload",
      status: :unprocessable_content,
      detail: "Validation failed.",
      instance: "/api/extensions",
      extensions: {
        errors: {
          extension: {
            name: ["must be a string"]
          }
        }
      }
    ]

    expect(json_payload).to eq(problem.to_h)
  end

  it "answers problem details for invalid ID" do
    patch routes.path(:api_extension, id: 13),
          {extension: {template: "<h1>Test</h2>"}}.to_json,
          "HTTP_AUTHORIZATION" => access_token,
          "CONTENT_TYPE" => "application/json"

    problem = RFC::API::Problem[status: :not_found]

    expect(json_payload).to eq(problem.to_h)
  end

  it "answers deleted extension" do
    delete routes.path(:api_extension, id: extension.id),
           {},
           "HTTP_AUTHORIZATION" => access_token,
           "CONTENT_TYPE" => "application/json"

    expect(json_payload).to match(
      data: {
        id: extension.id,
        label: extension.label,
        name: extension.name,
        description: nil,
        kind: "poll",
        mode: "text",
        tags: [],
        static_body: {},
        fields: [],
        template: "<h1>{{source_1.label}}</h1>",
        data: {},
        interval: 1,
        unit: "none",
        days: [],
        last_day_of_month: false,
        start_at: match_rfc_3339,
        created_at: match_rfc_3339,
        updated_at: match_rfc_3339
      }
    )
  end

  it "answers not found problem details when deleting non-existing screen" do
    delete routes.path(:api_extension, id: 666),
           {},
           "HTTP_AUTHORIZATION" => access_token,
           "CONTENT_TYPE" => "application/json"

    expect(json_payload).to eq(status: 404, title: "Not Found", type: "about:blank")
  end
end

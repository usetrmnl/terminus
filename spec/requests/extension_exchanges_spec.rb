# frozen_string_literal: true

require "hanami_helper"

RSpec.describe "/api/extensions/:extension_id/exchanges", :db do
  include_context "with JWT"

  let(:exchange) { Factory[:extension_exchange, template: "https://test.io"] }

  it "answers records when extensions exist" do
    exchange

    get routes.path(:api_extension_exchanges, extension_id: exchange.extension_id),
        {},
        "HTTP_AUTHORIZATION" => access_token,
        "CONTENT_TYPE" => "application/json"

    expect(json_payload).to match(
      data: [
        {
          id: exchange.id,
          headers: {},
          verb: "get",
          template: "https://test.io",
          body: {},
          data: {},
          errors: {},
          refreshed_at: nil,
          created_at: match_rfc_3339,
          updated_at: match_rfc_3339
        }
      ]
    )
  end

  it "answers empty array when extensions don't exist" do
    get routes.path(:api_extension_exchanges, extension_id: 1),
        {},
        "HTTP_AUTHORIZATION" => access_token,
        "CONTENT_TYPE" => "application/json"

    expect(json_payload).to eq(data: [])
  end

  it "answers existing extension" do
    get routes.path(:api_extension_exchange, extension_id: exchange.extension_id, id: exchange.id),
        {},
        "HTTP_AUTHORIZATION" => access_token,
        "CONTENT_TYPE" => "application/json"

    expect(json_payload).to match(
      data: {
        id: exchange.id,
        headers: {},
        verb: "get",
        template: "https://test.io",
        body: {},
        data: {},
        errors: {},
        refreshed_at: nil,
        created_at: match_rfc_3339,
        updated_at: match_rfc_3339
      }
    )
  end

  it "answers not found error with invalid ID" do
    get routes.path(:api_extension_exchange, extension_id: exchange.extension_id, id: 666),
        {},
        "HTTP_AUTHORIZATION" => access_token,
        "CONTENT_TYPE" => "application/json"

    expect(json_payload).to eq(RFC::API::Problem[status: :not_found].to_h)
  end

  it "creates extension" do
    extension = Factory[:extension]
    post routes.path(:api_extension_exchanges, extension_id: extension.id),
         {
           exchange: {
             headers: {"content-type" => "application/json"},
             verb: "get",
             template: "https://test.io/1"
           }
         }.to_json,
         "HTTP_AUTHORIZATION" => access_token,
         "CONTENT_TYPE" => "application/json"

    expect(json_payload).to match(
      data: {
        id: kind_of(Integer),
        headers: {"content-type": "application/json"},
        verb: "get",
        template: "https://test.io/1",
        body: {},
        data: {},
        errors: {},
        refreshed_at: nil,
        created_at: match_rfc_3339,
        updated_at: match_rfc_3339
      }
    )
  end

  context "without post body" do
    let(:extension) { Factory[:extension] }

    before do
      post routes.path(:api_extension_exchanges, extension_id: extension.id),
           {},
           "HTTP_AUTHORIZATION" => access_token,
           "CONTENT_TYPE" => "application/json"
    end

    it "answers problem details" do
      problem = RFC::API::Problem[
        type: "/problem_details#extension_exchange",
        status: :unprocessable_content,
        detail: "Validation failed.",
        instance: "/api/extensions/#{extension.id}/exchanges",
        extensions: {errors: {exchange: ["is missing"]}}
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
    path = routes.path :api_extension_exchange, extension_id: exchange.extension_id, id: exchange.id

    patch path,
          {exchange: {template: "https://httpbin.io/status/200"}}.to_json,
          "HTTP_AUTHORIZATION" => access_token,
          "CONTENT_TYPE" => "application/json"

    expect(json_payload).to match(
      data: {
        id: exchange.id,
        headers: {},
        verb: "get",
        template: "https://httpbin.io/status/200",
        body: {},
        data: {},
        errors: kind_of(Hash),
        refreshed_at: match_rfc_3339,
        created_at: match_rfc_3339,
        updated_at: match_rfc_3339
      }
    )
  end

  it "answers problem details for invalid value" do
    path = routes.path :api_extension_exchange, extension_id: exchange.extension_id, id: exchange.id

    patch path,
          {exchange: {headers: :bogus}}.to_json,
          "HTTP_AUTHORIZATION" => access_token,
          "CONTENT_TYPE" => "application/json"

    problem = RFC::API::Problem[
      type: "/problem_details#extension_exchange",
      status: :unprocessable_content,
      detail: "Validation failed.",
      instance: "/api/extensions/#{exchange.extension_id}/exchanges/#{exchange.id}",
      extensions: {
        errors: {
          exchange: {
            headers: ["must be a hash"]
          }
        }
      }
    ]

    expect(json_payload).to eq(problem.to_h)
  end

  it "answers problem details for invalid ID" do
    patch routes.path(:api_extension_exchange, extension_id: exchange.extension_id, id: 666),
          {exchange: {template: "https://test.io"}}.to_json,
          "HTTP_AUTHORIZATION" => access_token,
          "CONTENT_TYPE" => "application/json"

    problem = RFC::API::Problem[status: :not_found]

    expect(json_payload).to eq(problem.to_h)
  end

  it "answers deleted extension" do
    path = routes.path :api_extension_exchange, extension_id: exchange.extension_id, id: exchange.id

    delete path, {}, "HTTP_AUTHORIZATION" => access_token, "CONTENT_TYPE" => "application/json"

    expect(json_payload).to match(
      data: {
        id: exchange.id,
        headers: {},
        verb: "get",
        template: "https://test.io",
        body: {},
        data: {},
        errors: {},
        refreshed_at: nil,
        created_at: match_rfc_3339,
        updated_at: match_rfc_3339
      }
    )
  end

  it "answers not found problem details when deleting non-existing screen" do
    path = routes.path :api_extension_exchange, extension_id: exchange.extension_id, id: 666
    delete path, {}, "HTTP_AUTHORIZATION" => access_token, "CONTENT_TYPE" => "application/json"

    expect(json_payload).to eq(status: 404, title: "Not Found", type: "about:blank")
  end
end

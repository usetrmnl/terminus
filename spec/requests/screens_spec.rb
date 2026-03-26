# frozen_string_literal: true

require "hanami_helper"

RSpec.describe "/api/screens", :db do
  using Refinements::Pathname

  include_context "with JWT"

  let(:palette) { Factory[:palette] }
  let(:model) { Factory[:model, palette_names: [palette.name]] }
  let(:screen) { Factory[:screen, :with_image, model_id: model.id] }

  it "answers records when screens exist" do
    screen

    get routes.path(:api_screens),
        {},
        "HTTP_AUTHORIZATION" => access_token,
        "CONTENT_TYPE" => "application/json"

    expect(json_payload).to match(
      data: [
        {
          model_id: kind_of(Integer),
          id: kind_of(Integer),
          label: screen.label,
          name: screen.name,
          filename: "test.png",
          uri: "memory://abc123.png",
          mime_type: "image/png",
          bit_depth: 1,
          size: kind_of(Integer),
          width: 1,
          height: 1,
          created_at: match_rfc_3339,
          updated_at: match_rfc_3339
        }
      ]
    )
  end

  it "answers empty array when screens don't exist" do
    get routes.path(:api_screens),
        {},
        "HTTP_AUTHORIZATION" => access_token,
        "CONTENT_TYPE" => "application/json"

    expect(json_payload).to eq(data: [])
  end

  it "creates with playlist ID" do
    playlist = Factory[:playlist]

    post routes.path(:api_screen_create),
         {
           screen: {
             playlist_id: playlist.id,
             model_id: model.id,
             label: "Test",
             name: "test",
             content: "<p>n/a</p>"
           }
         }.to_json,
         "HTTP_AUTHORIZATION" => access_token,
         "CONTENT_TYPE" => "application/json"

    expect(json_payload).to match(
      data: {
        model_id: model.id,
        id: kind_of(Integer),
        label: "Test",
        name: "test",
        filename: "test.png",
        uri: %r(memory://\h{32}.png),
        mime_type: "image/png",
        bit_depth: 1,
        size: kind_of(Integer),
        width: 800,
        height: 480,
        created_at: match_rfc_3339,
        updated_at: match_rfc_3339
      }
    )
  end

  it "creates image from HTML" do
    post routes.path(:api_screen_create),
         {screen: {model_id: model.id, label: "Test", name: "test", content: "<p>n/a</p>"}}.to_json,
         "HTTP_AUTHORIZATION" => access_token,
         "CONTENT_TYPE" => "application/json"

    expect(json_payload).to match(
      data: {
        model_id: model.id,
        id: kind_of(Integer),
        label: "Test",
        name: "test",
        filename: "test.png",
        uri: %r(memory://\h{32}.png),
        mime_type: "image/png",
        bit_depth: 1,
        size: kind_of(Integer),
        width: 800,
        height: 480,
        created_at: match_rfc_3339,
        updated_at: match_rfc_3339
      }
    )
  end

  it "creates preprocessed image from URI" do
    payload = {
      screen: {
        model_id: model.id,
        label: "Test",
        name: "test",
        uri: SPEC_ROOT.join("support/fixtures/test.png"),
        preprocessed: true
      }
    }

    post routes.path(:api_screen_create),
         payload.to_json,
         "HTTP_AUTHORIZATION" => access_token,
         "CONTENT_TYPE" => "application/json"

    expect(json_payload).to match(
      data: {
        model_id: kind_of(Integer),
        id: kind_of(Integer),
        label: "Test",
        name: "test",
        filename: "test.png",
        uri: %r(memory://.+.png),
        mime_type: "image/png",
        bit_depth: 1,
        size: 81,
        width: 1,
        height: 1,
        created_at: match_rfc_3339,
        updated_at: match_rfc_3339
      }
    )
  end

  it "creates unprocessed image from URI" do
    payload = {
      screen: {
        model_id: model.id,
        label: "Test",
        name: "test",
        uri: SPEC_ROOT.join("support/fixtures/test.png")
      }
    }

    post routes.path(:api_screen_create),
         payload.to_json,
         "HTTP_AUTHORIZATION" => access_token,
         "CONTENT_TYPE" => "application/json"

    expect(json_payload).to match(
      data: {
        model_id: kind_of(Integer),
        id: kind_of(Integer),
        label: "Test",
        name: "test",
        filename: "test.png",
        uri: %r(memory://.+.png),
        mime_type: "image/png",
        bit_depth: 1,
        size: 126,
        width: 800,
        height: 480,
        created_at: match_rfc_3339,
        updated_at: match_rfc_3339
      }
    )
  end

  context "with existing record" do
    before do
      post routes.path(:api_screen_create),
           {
             screen: {
               model_id: model.id,
               label: screen.label,
               name: screen.name,
               content: "<p>Test.</p>"
             }
           }.to_json,
           "HTTP_AUTHORIZATION" => access_token,
           "CONTENT_TYPE" => "application/json"
    end

    it "answers problem details" do
      problem = Petail[
        type: "/problem_details#screen_payload",
        status: 422,
        title: "Unprocessable Content",
        detail: %(Screen exists with name (#{screen.name.inspect}) and model ID (#{model.id}).),
        instance: "/api/screens"
      ]

      expect(json_payload).to eq(problem.to_h)
    end
  end

  context "with unknown model" do
    before do
      post routes.path(:api_screen_create),
           {screen: {model_id: 666, label: "Test", name: "test", content: "<p>Test.</p>"}}.to_json,
           "HTTP_AUTHORIZATION" => access_token,
           "CONTENT_TYPE" => "application/json"
    end

    it "answers problem details" do
      problem = Petail[
        type: "/problem_details#screen_payload",
        status: 422,
        title: "Unprocessable Content",
        detail: "Unable to find model for model ID (666) or device ID (nil).",
        instance: "/api/screens"
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

  context "without body" do
    before do
      post routes.path(:api_screen_create),
           {},
           "HTTP_AUTHORIZATION" => access_token,
           "CONTENT_TYPE" => "application/json"
    end

    it "answers problem details" do
      problem = Petail[
        type: "/problem_details#screen_payload",
        status: :unprocessable_content,
        detail: "Validation failed.",
        instance: "/api/screens",
        extensions: {errors: {screen: ["is missing"]}}
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

  it "patches screen content" do
    patch routes.path(:api_screen_patch, id: screen.id),
          {screen: {content: "<p>Test</p>"}}.to_json,
          "HTTP_AUTHORIZATION" => access_token,
          "CONTENT_TYPE" => "application/json"

    expect(json_payload).to match(
      data: {
        model_id: screen.model_id,
        id: kind_of(Integer),
        label: screen.label,
        name: screen.name,
        filename: "#{screen.name}.png",
        uri: %r(memory://\h{32}.png),
        mime_type: "image/png",
        bit_depth: 1,
        size: kind_of(Integer),
        width: 800,
        height: 480,
        created_at: match_rfc_3339,
        updated_at: match_rfc_3339
      }
    )
  end

  it "patches screen model ID" do
    patch routes.path(:api_screen_patch, id: screen.id),
          {screen: {model_id: model.id, content: "<p>Test</p>"}}.to_json,
          "HTTP_AUTHORIZATION" => access_token,
          "CONTENT_TYPE" => "application/json"

    expect(json_payload).to match(
      data: {
        model_id: model.id,
        id: kind_of(Integer),
        label: screen.label,
        name: screen.name,
        filename: "#{screen.name}.png",
        uri: %r(memory://\h{32}.png),
        mime_type: "image/png",
        bit_depth: 1,
        size: kind_of(Integer),
        width: 800,
        height: 480,
        created_at: match_rfc_3339,
        updated_at: match_rfc_3339
      }
    )
  end

  it "answers problem details for invalid ID" do
    patch routes.path(:api_screen_patch, id: 13),
          {screen: {content: "<h1>Test</h2>"}}.to_json,
          "HTTP_AUTHORIZATION" => access_token,
          "CONTENT_TYPE" => "application/json"

    problem = Petail[
      type: "/problem_details#screen_payload",
      status: 422,
      title: "Unprocessable Content",
      detail: "Unable to find screen: 13.",
      instance: "/api/screens"
    ]

    expect(json_payload).to eq(problem.to_h)
  end

  it "answers problem details for invalid model ID" do
    patch routes.path(:api_screen_patch, id: screen.id),
          {screen: {model_id: 666, content: "<h1>Test</h2>"}}.to_json,
          "HTTP_AUTHORIZATION" => access_token,
          "CONTENT_TYPE" => "application/json"

    problem = Petail[
      type: "/problem_details#screen_payload",
      status: 422,
      title: "Unprocessable Content",
      detail: "Unable to find model for model ID (666) or device ID (nil).",
      instance: "/api/screens"
    ]

    expect(json_payload).to eq(problem.to_h)
  end

  it "answers problem details when payload has no content" do
    patch routes.path(:api_screen_patch, id: screen.id),
          {screen: {}}.to_json,
          "HTTP_AUTHORIZATION" => access_token,
          "CONTENT_TYPE" => "application/json"

    problem = Petail[
      type: "/problem_details#screen_payload",
      status: 422,
      title: "Unprocessable Content",
      detail: "Validation failed.",
      instance: "/api/screens",
      extensions: {
        errors: {
          screen: ["must be filled"]
        }
      }
    ]

    expect(json_payload).to eq(problem.to_h)
  end

  it "answers deleted screen" do
    delete routes.path(:api_screen_delete, id: screen.id),
           {},
           "HTTP_AUTHORIZATION" => access_token,
           "CONTENT_TYPE" => "application/json"

    expect(json_payload).to match(
      data: {
        model_id: kind_of(Integer),
        id: kind_of(Integer),
        label: screen.label,
        name: screen.name,
        filename: "test.png",
        uri: "memory://abc123.png",
        mime_type: "image/png",
        bit_depth: 1,
        size: kind_of(Integer),
        width: 1,
        height: 1,
        created_at: match_rfc_3339,
        updated_at: match_rfc_3339
      }
    )
  end

  it "answers not found problem details when deleting non-existing screen" do
    delete routes.path(:api_screen_delete, id: 666),
           {},
           "HTTP_AUTHORIZATION" => access_token,
           "CONTENT_TYPE" => "application/json"

    expect(json_payload).to eq(status: 404, title: "Not Found", type: "about:blank")
  end
end

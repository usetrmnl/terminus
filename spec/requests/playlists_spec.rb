# frozen_string_literal: true

require "hanami_helper"

RSpec.describe "/api/playlists", :db do
  include_context "with JWT"

  let(:item) { Factory[:playlist_item] }
  let(:playlist) { item.playlist }

  let :attributes do
    {
      name: "test",
      label: "Test"
    }
  end

  it "answers playlists" do
    item

    get routes.path(:api_playlists),
        {},
        "HTTP_AUTHORIZATION" => access_token,
        "CONTENT_TYPE" => "application/json"

    expect(json_payload).to match(
      data: [
        {
          id: playlist.id,
          label: playlist.label,
          name: playlist.name,
          current_item_id: nil,
          mode: "automatic",
          items: [
            {
              id: kind_of(Integer),
              screen_id: item.screen_id,
              position: kind_of(Integer),
              created_at: match_rfc_3339,
              updated_at: match_rfc_3339
            }
          ],
          created_at: match_rfc_3339,
          updated_at: match_rfc_3339
        }
      ]
    )
  end

  it "answers empty array when no records exist" do
    get routes.path(:api_playlists),
        {},
        "HTTP_AUTHORIZATION" => access_token,
        "CONTENT_TYPE" => "application/json"

    expect(json_payload).to eq(data: [])
  end

  it "answers existing playlist" do
    get routes.path(:api_playlist, id: playlist.id),
        {},
        "HTTP_AUTHORIZATION" => access_token,
        "CONTENT_TYPE" => "application/json"

    expect(json_payload).to match(
      data: {
        id: playlist.id,
        label: playlist.label,
        name: playlist.name,
        current_item_id: nil,
        mode: "automatic",
        items: [
          {
            id: kind_of(Integer),
            screen_id: item.screen_id,
            position: kind_of(Integer),
            created_at: match_rfc_3339,
            updated_at: match_rfc_3339
          }
        ],
        created_at: match_rfc_3339,
        updated_at: match_rfc_3339
      }
    )
  end

  it "answers not found error with invalid ID" do
    get routes.path(:api_playlist, id: 666),
        {},
        "HTTP_AUTHORIZATION" => access_token,
        "CONTENT_TYPE" => "application/json"

    expect(json_payload).to eq(Petail[status: :not_found].to_h)
  end

  it "creates playlist when valid" do
    screen = Factory[:screen]
    attributes[:items] = [{screen_id: screen.id}]

    post routes.path(:api_playlist_create),
         {playlist: attributes}.to_json,
         "HTTP_AUTHORIZATION" => access_token,
         "CONTENT_TYPE" => "application/json"

    expect(json_payload).to match(
      data: {
        id: kind_of(Integer),
        label: "Test",
        name: "test",
        current_item_id: kind_of(Integer),
        mode: "automatic",
        items: [
          {
            id: kind_of(Integer),
            screen_id: screen.id,
            position: kind_of(Integer),
            created_at: match_rfc_3339,
            updated_at: match_rfc_3339
          }
        ],
        created_at: match_rfc_3339,
        updated_at: match_rfc_3339
      }
    )
  end

  it "creates playlist without items" do
    post routes.path(:api_playlist_create),
         {playlist: attributes}.to_json,
         "HTTP_AUTHORIZATION" => access_token,
         "CONTENT_TYPE" => "application/json"

    expect(json_payload).to match(
      data: {
        id: kind_of(Integer),
        label: "Test",
        name: "test",
        current_item_id: nil,
        mode: "automatic",
        items: [],
        created_at: match_rfc_3339,
        updated_at: match_rfc_3339
      }
    )
  end

  it "answers error when creation fails" do
    attributes.delete :name

    post routes.path(:api_playlists),
         {playlist: attributes}.to_json,
         "HTTP_AUTHORIZATION" => access_token,
         "CONTENT_TYPE" => "application/json"

    problem = Petail[
      type: "/problem_details#playlist_payload",
      status: :unprocessable_content,
      detail: "Validation failed.",
      instance: "/api/playlists",
      extensions: {
        errors: {
          playlist: {
            name: ["is missing"]
          }
        }
      }
    ]

    expect(json_payload).to match(problem.to_h)
  end

  it "patches playlist when valid" do
    screen = Factory[:screen]
    attributes[:items] = [{screen_id: screen.id}]

    patch routes.path(:api_playlist_patch, id: playlist.id),
          {playlist: attributes}.to_json,
          "HTTP_AUTHORIZATION" => access_token,
          "CONTENT_TYPE" => "application/json"

    expect(json_payload).to match(
      data: {
        id: playlist.id,
        label: "Test",
        name: "test",
        current_item_id: nil,
        mode: "automatic",
        items: [
          {
            id: kind_of(Integer),
            screen_id: screen.id,
            position: kind_of(Integer),
            created_at: match_rfc_3339,
            updated_at: match_rfc_3339
          }
        ],
        created_at: match_rfc_3339,
        updated_at: match_rfc_3339
      }
    )
  end

  it "patches current item ID" do
    attributes[:current_item_id] = item.id

    patch routes.path(:api_playlist_patch, id: playlist.id),
          {playlist: attributes}.to_json,
          "HTTP_AUTHORIZATION" => access_token,
          "CONTENT_TYPE" => "application/json"

    expect(json_payload).to match(
      data: {
        id: playlist.id,
        label: "Test",
        name: "test",
        current_item_id: item.id,
        mode: "automatic",
        items: [
          {
            id: kind_of(Integer),
            screen_id: item.screen_id,
            position: kind_of(Integer),
            created_at: match_rfc_3339,
            updated_at: match_rfc_3339
          }
        ],
        created_at: match_rfc_3339,
        updated_at: match_rfc_3339
      }
    )
  end

  it "answers error when patch fails" do
    patch routes.path(:api_playlist_patch, id: playlist.id),
          {playlist: {}}.to_json,
          "HTTP_AUTHORIZATION" => access_token,
          "CONTENT_TYPE" => "application/json"

    problem = Petail[
      type: "/problem_details#playlist_payload",
      status: :unprocessable_content,
      detail: "Validation failed.",
      instance: "/api/playlists",
      extensions: {
        errors: {
          playlist: ["must be filled"]
        }
      }
    ]

    expect(json_payload).to match(problem.to_h)
  end

  it "deletes existing record" do
    delete routes.path(:api_playlist_delete, id: playlist.id),
           {},
           "HTTP_AUTHORIZATION" => access_token,
           "CONTENT_TYPE" => "application/json"

    expect(json_payload).to match(
      data: {
        id: playlist.id,
        label: playlist.label,
        name: playlist.name,
        current_item_id: nil,
        mode: "automatic",
        items: [
          {
            id: kind_of(Integer),
            screen_id: item.screen_id,
            position: kind_of(Integer),
            created_at: match_rfc_3339,
            updated_at: match_rfc_3339
          }
        ],
        created_at: match_rfc_3339,
        updated_at: match_rfc_3339
      }
    )
  end

  it "answers empty payload with invalid ID" do
    delete routes.path(:api_playlist_delete, id: 666),
           {},
           "HTTP_AUTHORIZATION" => access_token,
           "CONTENT_TYPE" => "application/json"

    expect(json_payload).to match(data: {})
  end
end

# frozen_string_literal: true

require "hanami_helper"

RSpec.describe Terminus::Aspects::HomeAssistant::UrlNormalizer do
  subject(:normalizer) { described_class.new }

  it "creates entity_picture_url while preserving entity_picture" do
    payload = {"attributes" => {"entity_picture" => "/api/media_player_proxy/one?token=abc"}}
    api_uri = Hanami.app[:settings].api_uri.to_s.sub %r(/+\z), ""
    entity_picture_url = "#{api_uri}/home-assistant/media?" \
                         "path=%2Fapi%2Fmedia_player_proxy%2Fone%3Ftoken%3Dabc"
    result = normalizer.call payload, "http://ha.local:8123"

    expect(result).to include(
      "attributes" => {
        "entity_picture" => "/api/media_player_proxy/one?token=abc",
        "entity_picture_url" => entity_picture_url
      }
    )
  end
end

# frozen_string_literal: true

require "hanami_helper"

RSpec.describe Terminus::Aspects::HomeAssistant::EntityFetcher do
  subject(:fetcher) { described_class.new client:, url_normalizer: Terminus::Aspects::HomeAssistant::UrlNormalizer.new }

  let(:connection) { Factory.structs[:home_assistant_connection, base_url: "http://ha.local:8123"] }

  context "with one entity" do
    let :entity do
      {
        "entity_id" => "media_player.sonos_roam",
        "attributes" => {"entity_picture" => "/api/media?a=1"}
      }
    end
    let(:client) { instance_double Terminus::Aspects::HomeAssistant::Client, call: Success(entity) }

    it "fetches one entity" do
      result = fetcher.call connection, entity_ids: ["media_player.sonos_roam"]
      expect(result.value!.first).to include(
        "attributes" => a_hash_including(
          "entity_picture" => "/api/media?a=1",
          "entity_picture_url" => include("/home-assistant/media?path=")
        )
      )
    end
  end

  context "with many entities" do
    let(:entity_one) { {"entity_id" => "one", "state" => "on"} }
    let(:entity_two) { {"entity_id" => "two", "state" => "off"} }
    let :client do
      instance_double(Terminus::Aspects::HomeAssistant::Client).tap do |double|
        allow(double).to receive(:call).and_return(Success(entity_one), Success(entity_two))
      end
    end

    it "fetches multiple entities" do
      expect(
        fetcher.call(
          connection,
          entity_ids: %w[one two]
        )
      ).to be_success([entity_one, entity_two])
    end
  end
end

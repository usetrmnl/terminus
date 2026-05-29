# frozen_string_literal: true

require "hanami_helper"

RSpec.describe Terminus::Aspects::Extensions::Renderers::HomeAssistant, :db do
  subject :renderer do
    described_class.new(
      connection_repository: Terminus::Repositories::HomeAssistantConnection.new,
      config_repository: Terminus::Repositories::ExtensionHomeAssistantConfig.new,
      entity_fetcher:,
      endpoint_fetcher:,
      renderer: Hanami.app["liquid.sanitize"],
      logger: Hanami.app[:logger]
    )
  end

  let(:entity_fetcher) { instance_double Terminus::Aspects::HomeAssistant::EntityFetcher }
  let(:endpoint_fetcher) { instance_double Terminus::Aspects::HomeAssistant::EndpointFetcher }
  let :aliased_entities do
    [
      {"entity_id" => "media_player.sonos_roam", "state" => "playing"},
      {"entity_id" => "media_player.office", "state" => "paused"}
    ]
  end

  let :attribute_aliases do
    {
      "aliases" => {
        "roam" => "media_player.sonos_roam",
        "office" => "media_player.office"
      }
    }
  end

  before { Factory[:home_assistant_connection] }

  it "exposes one entity as source" do
    extension = build_extension "{{source.state}} {{entities.size}}"
    Factory[:extension_home_assistant_config,
            extension_id: extension.id,
            source_mode: "entity",
            entity_ids: ["media_player.sonos_roam"]]
    allow(entity_fetcher).to receive(:call).and_return(
      Success(
        [
          {
            "entity_id" => "media_player.sonos_roam", "state" => "playing"
          }
        ]
      )
    )

    result = renderer.call extension
    expect(result.value!).to include("playing")
  end

  it "does not expose access token in rendered output" do
    extension = build_extension "{{source.state}} {{home_assistant.access_token}}"
    Factory[:extension_home_assistant_config,
            extension_id: extension.id,
            source_mode: "entity",
            entity_ids: ["media_player.sonos_roam"]]
    allow(entity_fetcher).to receive(:call).and_return(
      Success(
        [
          {
            "entity_id" => "media_player.sonos_roam", "state" => "playing"
          }
        ]
      )
    )

    result = renderer.call extension
    expect(result.value!).not_to include("token123")
  end

  it "exposes multiple entities as entities" do
    extension = build_extension "{{source.state}} {{entities.size}}"
    Factory[:extension_home_assistant_config,
            extension_id: extension.id,
            source_mode: "entity",
            entity_ids: %w[one two]]
    allow(entity_fetcher).to receive(:call).and_return(
      Success(
        [
          {"entity_id" => "one", "state" => "on"},
          {"entity_id" => "two", "state" => "off"}
        ]
      )
    )

    result = renderer.call extension
    expect(result.value!).to include("2")
  end

  it "exposes alias variables via attribute map" do
    extension = build_extension "{{ha.roam.state}} {{home_assistant.aliases.office.state}}"
    Factory[
      :extension_home_assistant_config,
      extension_id: extension.id,
      source_mode: "entity",
      entity_ids: ["media_player.sonos_roam", "media_player.office"],
      attribute_map: attribute_aliases
    ]
    allow(entity_fetcher).to receive(:call).and_return(Success(aliased_entities))

    result = renderer.call extension
    expect(result.value!).to include("playing paused")
  end

  def build_extension template
    Factory[:extension, kind: "home_assistant", template:]
  end
end

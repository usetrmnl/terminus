# frozen_string_literal: true

require "hanami_helper"

RSpec.describe Terminus::Aspects::HomeAssistant::EndpointFetcher do
  subject(:fetcher) { described_class.new client:, url_normalizer: Terminus::Aspects::HomeAssistant::UrlNormalizer.new }

  let(:connection) { Factory.structs[:home_assistant_connection] }
  let(:client) { instance_double Terminus::Aspects::HomeAssistant::Client, call: Success({"ok" => true}) }

  it "rejects external URLs" do
    expect(fetcher.call(connection, endpoint_path: "https://evil.io/api/states")).to be_failure(
      "Home Assistant endpoint path must be relative."
    )
  end

  it "accepts /api/states" do
    expect(fetcher.call(connection, endpoint_path: "/api/states")).to be_success("ok" => true)
  end
end

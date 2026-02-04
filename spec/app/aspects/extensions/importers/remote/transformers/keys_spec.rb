# frozen_string_literal: true

require "hanami_helper"

RSpec.describe Terminus::Aspects::Extensions::Importers::Remote::Transformers::Keys do
  subject(:transformer) { described_class.new }

  describe "#call" do
    let :attributes do
      {
        custom_fields: [
          {
            "keyname" => "test",
            "field_type" => "url",
            "name" => "https://test.io"
          }
        ],
        dark_mode: "yes",
        name: "Test",
        polling_body: %({"sort":"name", "limit": 10}),
        polling_headers: "accept=application/json&content-type=application/json",
        polling_url: "https://test.io/test",
        polling_verb: "get",
        refresh_interval: 100
      }
    end

    let :proof do
      {
        fields: [
          {
            "keyname" => "test",
            "field_type" => "url",
            "name" => "https://test.io"
          }
        ],
        label: "Test",
        body: %({"sort":"name", "limit": 10}),
        headers: "accept=application/json&content-type=application/json",
        uris: "https://test.io/test",
        verb: "get",
        interval: 100
      }
    end

    it "answers updated and deleted keys" do
      expect(transformer.call(attributes)).to be_success(proof)
    end
  end
end

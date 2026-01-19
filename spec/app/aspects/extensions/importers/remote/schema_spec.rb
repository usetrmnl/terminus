# frozen_string_literal: true

require "hanami_helper"

RSpec.describe Terminus::Aspects::Extensions::Importers::Remote::Schema do
  subject(:schema) { described_class }

  describe "#call" do
    let :attributes do
      {
        custom_fields: [],
        dark_mode: "no",
        name: "Test",
        polling_body: "",
        polling_headers: "",
        polling_url: "https://test.io/test",
        polling_verb: "get",
        refresh_interval: 100,
        static_data: "",
        strategy: "polling"
      }
    end

    it "answers valid attributes" do
      result = schema.call attributes

      expect(result.to_h).to eq(
        custom_fields: [],
        dark_mode: false,
        name: "Test",
        polling_body: nil,
        polling_headers: nil,
        polling_url: "https://test.io/test",
        polling_verb: "get",
        refresh_interval: 100,
        static_data: nil,
        strategy: "polling"
      )
    end

    it "coerces polling body to JSON" do
      body = {"sort" => "name", "search" => "test"}
      attributes[:polling_body] = body.to_json

      expect(schema.call(attributes)[:polling_body]).to eq(body)
    end

    it "coerces polling headers to JSON" do
      attributes[:polling_headers] = "accept=application/json&content-type=application/json"

      expect(schema.call(attributes)[:polling_headers]).to eq(
        "accept" => "application/json",
        "content-type" => "application/json"
      )
    end

    it "coerces static body to JSON" do
      body = {"name" => "Test"}
      attributes[:static_data] = body.to_json

      expect(schema.call(attributes)[:static_data]).to eq(body)
    end
  end
end

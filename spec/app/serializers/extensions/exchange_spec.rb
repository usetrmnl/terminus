# frozen_string_literal: true

require "hanami_helper"

RSpec.describe Terminus::Serializers::Extensions::Exchange do
  subject(:serializer) { described_class.new exchange }

  let(:exchange) { Factory.structs[:extension_exchange, **attributes] }

  let :attributes do
    {
      id: 1,
      headers: {"content-type" => "application/json"},
      verb: "get",
      template: "<h1>Test</h1>",
      body: {},
      data: {},
      errors: {},
      refreshed_at: Time.new(2025, 1, 1, 0, 0, 0),
      created_at: Time.new(2025, 1, 1, 0, 0, 0),
      updated_at: Time.new(2025, 1, 1, 0, 0, 0)
    }
  end

  describe "#to_h" do
    it "answers hash" do
      expect(serializer.to_h).to match(
        id: 1,
        headers: {"content-type" => "application/json"},
        verb: "get",
        template: "<h1>Test</h1>",
        body: {},
        data: {},
        errors: {},
        refreshed_at: match_rfc_3339,
        created_at: match_rfc_3339,
        updated_at: match_rfc_3339
      )
    end
  end
end

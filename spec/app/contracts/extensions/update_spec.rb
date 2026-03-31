# frozen_string_literal: true

require "hanami_helper"

RSpec.describe Terminus::Contracts::Extensions::Update do
  subject(:contract) { described_class.new }

  describe "#call" do
    let :attributes do
      {
        id: 1,
        extension: {
          name: "test",
          label: "Test",
          description: nil,
          mode: "text",
          kind: "static",
          tags: ["test"],
          headers: "{}",
          verb: "get",
          uris: [],
          body: "{}",
          fields: "[]",
          template: nil,
          data: "{}",
          interval: 1,
          unit: "none",
          days: [],
          last_day_of_month: false,
          start_at: "2025-01-01T00:00:00"
        }
      }
    end

    it_behaves_like "an extension contract"
  end
end

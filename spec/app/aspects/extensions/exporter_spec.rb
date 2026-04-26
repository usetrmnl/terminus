# frozen_string_literal: true

require "hanami_helper"

RSpec.describe Terminus::Aspects::Extensions::Exporter, :db do
  subject(:exporter) { described_class.new }

  include_context "with application dependencies"

  describe "#call" do
    let(:extension) { Factory[:extension] }

    let :exchange do
      Factory[
        :extension_exchange,
        extension_id: extension.id,
        headers: {content_type: "application/json"},
        body: {sort: :desc},
        template: "https://test.io"
      ]
    end

    it "exports attributes" do
      exchange

      expect(exporter.call(extension)).to be_success(
        version: "1.2.3",
        name: extension.name,
        label: extension.label,
        description: nil,
        mode: "text",
        kind: "poll",
        tags: [],
        static_body: {},
        fields: [],
        template: nil,
        data: {},
        interval: 1,
        unit: "none",
        days: [],
        last_day_of_month: false,
        start_at: "2025-01-01T00:00:00+00:00",
        exchanges: [
          {
            headers: {"content_type" => "application/json"},
            verb: "get",
            template: "https://test.io",
            body: {"sort" => "desc"}
          }
        ]
      )
    end
  end
end

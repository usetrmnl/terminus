# frozen_string_literal: true

require "hanami_helper"

RSpec.describe Terminus::Aspects::Extensions::Exporter, :db do
  subject(:exporter) { described_class.new }

  describe "#call" do
    let(:extension) { Factory[:extension] }
    let(:exchange) { Factory[:extension_exchange] }

    it "exports YAML" do
      expect(exporter.call(extension.id)).to eq(
        name: "test",
        label: "Test",
        description: "This is a test.",
        mode: "dither",
        kind: "poll",
        body: "",
        fields: {
          a: 1
        },
        template: "",
        data: {a: 1},
        interval: 5,
        unit: "hour",
        day: {},
        last_day_of_month: true,
        start_at: "2026-04-24T20:20:20",
        exchanges: [
          {
            headers: {"accept" => "application/json"},
            verb: "post",
            template: "https://test.io",
            body: ""
          }
        ]
      )
    end
  end
end

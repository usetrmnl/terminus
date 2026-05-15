# frozen_string_literal: true

require "hanami_helper"
require "zip"

RSpec.describe Terminus::Aspects::Extensions::Exporter, :db do
  subject(:exporter) { described_class.new }

  include_context "with application dependencies"

  describe "#call" do
    let(:extension) { Factory[:extension, template: "https://test.io"] }

    let :exchange do
      Factory[
        :extension_exchange,
        extension_id: extension.id,
        headers: {content_type: "application/json"},
        body: {sort: :desc},
        template: "https://test.io"
      ]
    end

    let :proof do
      exporter.call(extension)
              .bind { Terminus::Aspects::Unzipper.new.call it }
              .value!
    end

    it "includes template" do
      expect(proof["template.html.liquid"]).to eq("https://test.io")
    end

    it "includes configuration" do
      exchange

      expect(proof["configuration.yml"]).to eq(<<~CONTENT)
        ---
        version: 1.2.3
        name: #{extension.name}
        label: #{extension.label}
        description:
        mode: text
        kind: poll
        tags: []
        static_body: {}
        fields: []
        data: {}
        interval: 1
        unit: none
        days: []
        last_day_of_month: false
        start_at: '2025-01-01T00:00:00+00:00'
        exchanges:
        - headers:
            content_type: application/json
          verb: get
          body:
            sort: desc
          template: https://test.io
      CONTENT
    end

    it "answers StringIO instance" do
      expect(exporter.call(extension)).to match(Success(kind_of(StringIO)))
    end
  end
end

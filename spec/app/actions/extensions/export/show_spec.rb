# frozen_string_literal: true

require "hanami_helper"
require "trmnl/api"

RSpec.describe Terminus::Actions::Extensions::Export::Show, :db do
  subject(:action) { described_class.new }

  include_context "with application dependencies"

  describe "#call" do
    let(:extension) { Factory[:extension] }

    it "renders YAML when success" do
      response = action.call Rack::MockRequest.env_for(
        "",
        "router.params" => {extension_id: extension.id}
      )

      expect(response.body.first).to eq(<<~CONTENT)
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
        template:
        data: {}
        interval: 1
        unit: none
        days: []
        last_day_of_month: false
        start_at: '2025-01-01T00:00:00+00:00'
        exchanges: []
      CONTENT
    end

    it "renders YAML with error when failure" do
      exporter = instance_double Terminus::Aspects::Extensions::Exporter, call: Failure("Danger!")
      action = described_class.new(exporter:)

      response = action.call Rack::MockRequest.env_for(
        "",
        "router.params" => {extension_id: extension.id}
      )

      expect(response.body.first).to eq(<<~CONTENT)
        ---
        error: Danger!
      CONTENT
    end

    it "answers unprocessable entity with invalid parameters" do
      response = action.call Rack::MockRequest.env_for("")
      expect(response.status).to eq(422)
    end
  end
end

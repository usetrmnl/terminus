# frozen_string_literal: true

require "hanami_helper"
require "trmnl/api"

RSpec.describe Terminus::Actions::Models::Export::Show, :db do
  subject(:action) { described_class.new }

  include_context "with application dependencies"

  describe "#call" do
    let(:model) { Factory[:model] }
    let(:unzipper) { Terminus::Aspects::Unzipper.new }

    it "renders zip when success" do
      response = action.call Rack::MockRequest.env_for("", "router.params" => {id: model.id})
      keys = unzipper.call(response.body.first).value!.keys

      expect(keys).to eq(%w[configuration.yml])
    end

    it "renders error when failure" do
      exporter = instance_double Terminus::Aspects::Models::Exporter, call: Failure("Danger!")
      action = described_class.new(exporter:)
      response = action.call Rack::MockRequest.env_for("", "router.params" => {id: model.id})

      expect(response.body.first).to eq("Danger!")
    end

    it "answers unprocessable entity with invalid parameters" do
      response = action.call Rack::MockRequest.env_for("")
      expect(response.status).to eq(422)
    end
  end
end

# frozen_string_literal: true

require "hanami_helper"

RSpec.describe Terminus::Actions::Extensions::Create, :db do
  subject(:action) { described_class.new }

  describe "#call" do
    let :params do
      {
        extension: {
          model_ids: [],
          label: "Test",
          name: "test",
          description: nil,
          kind: "poll",
          tags: nil,
          headers: nil,
          verb: "get",
          uris: "https://test.io/tests.json",
          body: nil,
          fields: nil,
          template: nil,
          data: nil,
          interval: 1,
          unit: "minute",
          days: [],
          last_day_of_month: false,
          start_at: "2025-01-01T00:00:00"
        }
      }
    end

    it "renders default response" do
      response = Rack::MockRequest.new(action).post("", params:)
      expect(response.body).to include("<!DOCTYPE html>")
    end

    it "renders htmx response" do
      response = Rack::MockRequest.new(action).post("", "HTTP_HX_REQUEST" => "true", params:)
      expect(response.body).to have_htmx_title("Extensions")
    end
  end
end

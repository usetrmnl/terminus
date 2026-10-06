# frozen_string_literal: true

require "hanami_helper"

RSpec.describe Terminus::Actions::Firmware::New, :db do
  subject(:action) { described_class.new }

  describe "#call" do
    let(:firmware) { Factory[:firmware] }
    let(:params) { {firmware: {version: "0.0.0"}} }

    it "renders default response" do
      response = Rack::MockRequest.new(action).post("", params:)
      expect(response.body).to include("<!DOCTYPE html>")
    end

    it "renders htmx response" do
      response = Rack::MockRequest.new(action).post("", "HTTP_HX_REQUEST" => "true", params:)
      expect(response.body).to have_htmx_title("New Firmware")
    end
  end
end

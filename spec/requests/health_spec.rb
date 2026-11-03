# frozen_string_literal: true

require "hanami_helper"

RSpec.describe "/up" do
  # Probes that follow redirects, such as Kubernetes HTTP probes, must not land on the login page.
  it "answers green background without login", :aggregate_failures do
    get "/up"

    expect(last_response.status).to eq(200)
    expect(last_response.body).to include(%(<main style="background-color: green;))
  end
end

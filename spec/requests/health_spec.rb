# frozen_string_literal: true

require "hanami_helper"

RSpec.describe "/up" do
  # Probes that follow redirects, such as Kubernetes HTTP probes, must not land on the login page.
  it "answers green background without login", :aggregate_failures do
    get "/up"

    expect(last_response.status).to eq(200)
    expect(last_response.body).to include(%(<main style="background-color: green;))
  end

  # A probe must see the failure itself, not a redirect that hides it.
  it "answers red background without login when unhealthy" do
    action = Health::Actions::Show.new.dup
    def action.handle(*) = fail StandardError, "Danger!"
    allow(Health::Slice).to receive(:resolve).and_call_original
    allow(Health::Slice).to receive(:resolve).with("actions.show").and_return(action)

    get "/up"

    expect(last_response.body).to include(%(<main style="background-color: red;))
  end

  # Guards against the authorize override spreading beyond the health check.
  it "still redirects other pages to login", :aggregate_failures do
    get "/devices"

    expect(last_response.status).to eq(302)
    expect(last_response.headers["Location"]).to end_with("/login")
  end
end

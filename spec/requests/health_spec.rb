# frozen_string_literal: true

require "hanami_helper"

RSpec.describe "/up" do
  it "answers healthy status" do
    get "/up"
    expect(last_response.status).to eq(200)
  end
end

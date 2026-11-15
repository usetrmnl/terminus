# frozen_string_literal: true

require "hanami_helper"

RSpec.describe "/login" do
  it "prevents view cache memory growth" do
    get "/login"

    size = Hanami::View.cache.cache.size

    3.times { get "/login" }

    expect(Hanami::View.cache.cache.size).to eq(size)
  end
end

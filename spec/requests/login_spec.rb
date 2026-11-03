# frozen_string_literal: true

require "hanami_helper"

RSpec.describe "/login" do
  # Guards against building a view per render, which grows Puma's memory without bound.
  it "doesn't grow view cache when rendered repeatedly" do
    get "/login"
    size = Hanami::View.cache.cache.size
    3.times { get "/login" }

    expect(Hanami::View.cache.cache.size).to eq(size)
  end
end

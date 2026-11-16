# frozen_string_literal: true

require "hanami_helper"

RSpec.describe Health::Actions::Show do
  subject(:action) { described_class.new }

  it "answers healthy status when up" do
    response = action.call Hash.new
    expect(response.body.first).to include("background-color: green")
  end

  it "answers unhealthy status when down" do
    implementation = Class.new described_class do
      def handle(*) = fail StandardError, "Danger!"
    end

    response = implementation.new(view: Health::Slice["views.show"]).call Hash.new

    expect(response.body.first).to include("background-color: red")
  end
end

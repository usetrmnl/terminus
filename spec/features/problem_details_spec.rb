# frozen_string_literal: true

require "hanami_helper"

RSpec.describe "Problem Details", :db do
  it "renders page" do
    visit routes.path(:problem_details)
    expect(page).to have_content("Problem Details")
  end
end

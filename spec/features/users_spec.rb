# frozen_string_literal: true

require "hanami_helper"

RSpec.describe "Users", :db do
  it "creates", :aggregate_failures, :js do
    visit routes.path(:users)
    click_link "New"
    fill_in "Name", with: "Test User"
    click_button "Save"

    expect(page).to have_content("must be filled")

    fill_in "Email", with: "test@test.io"
    fill_in "Password", with: "test-1234567890"
    select "Unverified", from: "Status"

    click_button "Save"

    expect(page).to have_content("test@test.io")
  end

  it "edits", :aggregate_failures, :js do
    user = Factory[:user]
    visit routes.path(:users)

    within ".bit-card", text: user.name do
      click_link "Edit"
    end

    fill_in "Name", with: nil
    click_button "Save"

    expect(page).to have_content("must be filled")

    fill_in "Name", with: "Test User"
    select "Closed", from: "Status"
    click_button "Save"

    expect(page).to have_content("Test User")
    expect(page).to have_content("Closed")
  end
end

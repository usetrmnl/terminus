# frozen_string_literal: true

require "hanami_helper"

RSpec.describe "Users", :db do
  it "creates and edits user", :aggregate_failures, :js do
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

    user = Terminus::Repositories::User.new.find_by email: "test@test.io"
    within("li[id='#{user.id}']") { click_link "Edit" }
    fill_in "Name", with: nil
    click_button "Save"

    expect(page).to have_content("must be filled")

    fill_in "Name", with: "Test II"
    select "Closed", from: "Status"
    click_button "Save"

    expect(page).to have_content("Test II")
    expect(page).to have_content("Closed")
  end
end

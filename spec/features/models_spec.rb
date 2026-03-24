# frozen_string_literal: true

require "hanami_helper"

RSpec.describe "Models", :db do
  it "creates, edits, clones, and deletes model", :aggregate_failures, :js do
    visit routes.path(:models)
    click_link "New"
    fill_in "model[label]", with: "Test"

    click_button "Save"

    expect(page).to have_content("must be filled")

    fill_in "model[name]", with: "test"
    click_button "Save"

    expect(page).to have_content("Test")

    click_link "Edit"
    fill_in "model[label]", with: ""
    click_button "Save"

    expect(page).to have_content("must be filled")

    fill_in "model[label]", with: "Test II"
    click_button "Save"

    expect(page).to have_content("Test II")

    visit routes.path(:models)
    click_link "Clone"
    fill_in "model[name]", with: ""
    click_button "Save"

    expect(page).to have_content("must be filled")

    fill_in "Name", with: "test"
    click_button "Save"

    expect(page).to have_content("must be unique")

    fill_in "model[name]", with: "test_clone"
    click_button "Save"

    expect(page).to have_content("Test II Clone")

    visit routes.path(:models)

    within ".bit-card", text: "Test II Clone" do
      accept_prompt { click_button "Delete" }
    end

    expect(page).to have_no_content("Test II Clone")
  end
end

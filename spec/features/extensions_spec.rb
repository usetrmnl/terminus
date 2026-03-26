# frozen_string_literal: true

require "hanami_helper"

RSpec.describe "Extensions", :db do
  it "creates extension", :aggregate_failures, :js do
    visit routes.path(:extensions)
    click_link "New"
    fill_in "extension[label]", with: "Test"
    click_button "Save"

    expect(page).to have_content("must be filled")

    fill_in "extension[name]", with: "test"
    click_button "Save"

    expect(page).to have_content("Test")
    expect(page).to have_content("poll")
  end

  it "edits, saves, builds, clones, and deletes extension", :aggregate_failures, :js do
    Factory[:model, name: "og_plus"]
    extension = Factory[:extension]

    visit routes.path(:extension_edit, id: extension.id)
    fill_in "extension[label]", with: nil
    click_button "Save"

    expect(page).to have_content("must be filled")

    fill_in "extension[label]", with: "Test"
    click_button "Save"

    expect(page).to have_content("Changes saved.")
    expect(page).to have_field(with: "Test")

    click_button "Build"

    expect(page).to have_content("Enqueuing...")

    click_link "Cancel"
    click_link "Clone"
    fill_in "extension[label]", with: nil
    click_button "Save"

    expect(page).to have_content("must be filled")

    fill_in "extension[label]", with: "Clone Test"
    click_button "Save"

    expect(page).to have_content("Clone Test")

    visit routes.path(:extensions)

    within ".bit-card", text: "Clone Test" do
      accept_prompt { click_button "Delete" }
    end

    expect(page).to have_no_content("Clone Test")
  end

  it "views gallery", :aggregate_failures do
    Hanami.app.start :trmnl_api
    visit routes.path(:extensions_gallery)

    expect(page).to have_content("Gallery")
    expect(page).to have_content("connection")
  end
end

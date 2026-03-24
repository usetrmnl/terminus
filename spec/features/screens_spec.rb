# frozen_string_literal: true

require "hanami_helper"

RSpec.describe "Screens", :db do
  let(:path) { SPEC_ROOT.join "support/fixtures/test.png" }

  it "creates, edits, and deletes screens", :aggregate_failures, :js do
    model = Factory[:model]

    visit routes.path(:screens)
    click_link "New"
    click_button "Save"

    expect(page).to have_content("must be filled")

    select model.label, from: "screen[model_id]"
    fill_in "screen[label]", with: "Test"
    fill_in "screen[name]", with: "test"
    attach_file "Image", path
    click_button "Save"

    expect(page).to have_content("Test")

    click_link "Edit"
    click_button "Save"

    expect(page).to have_content("Test")

    click_link "Edit"
    fill_in "screen[label]", with: ""
    click_button "Save"

    expect(page).to have_content("must be filled")

    fill_in "screen[label]", with: "Test II"
    attach_file "Image", path
    click_button "Save"

    expect(page).to have_content("Test II")

    visit routes.path(:firmware)
    accept_prompt { click_button "Delete" }

    expect(page).to have_no_content("Test")
  end
end

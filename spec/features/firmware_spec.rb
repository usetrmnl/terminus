# frozen_string_literal: true

require "hanami_helper"

RSpec.describe "Firmware", :db do
  include_context "with temporary directory"

  let(:path) { temp_dir.join("test.bin").tap { it.binwrite [123].pack("N") } }

  it "creates, edits, and deletes firmware", :aggregate_failures, :js do
    visit routes.path(:firmware)
    click_link "New"
    click_button "Save"

    expect(page).to have_content("must be filled")

    fill_in "firmware[version]", with: "0.0.0"
    click_button "Save"

    expect(page).to have_content("is missing")
    attach_file "Attachment", path
    click_button "Save"

    expect(page).to have_content("0.0.0")

    click_link "Edit"
    fill_in "firmware[version]", with: nil
    click_button "Save"

    expect(page).to have_content("must be filled")

    fill_in "firmware[version]", with: "0.0.1"
    click_button "Save"

    expect(page).to have_content("0.0.1")

    click_link "Edit"
    attach_file "Attachment", path
    click_button "Save"

    expect(page).to have_content("0.0.1")

    visit routes.path(:firmware)
    accept_prompt { click_button "Delete" }

    expect(page).to have_no_content("0.0.1")
  end
end

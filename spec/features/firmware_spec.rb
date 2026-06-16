# frozen_string_literal: true

require "hanami_helper"

RSpec.describe "Firmware", :db do
  include_context "with temporary directory"

  let(:firmware) { Factory[:firmware, :with_attachment] }
  let(:path) { temp_dir.join("test.bin").tap { it.binwrite [123].pack("N") } }

  it "creates", :aggregate_failures, :js do
    visit routes.path(:firmwares)
    click_link "New"
    click_button "Save"

    expect(page).to have_text("must be filled")

    fill_in "firmware[version]", with: "0.0.0"
    click_button "Save"

    expect(page).to have_text("is missing")
    attach_file "Attachment", path
    click_button "Save"

    expect(page).to have_text("0.0.0")
  end

  it "edits", :aggregate_failures, :js do
    firmware
    visit routes.path(:firmwares)
    click_link "Edit"
    fill_in "firmware[version]", with: nil
    click_button "Save"

    expect(page).to have_text("must be filled")

    fill_in "firmware[version]", with: "0.0.1"
    click_button "Save"

    expect(page).to have_text("0.0.1")

    click_link "Edit"
    attach_file "Attachment", path
    click_button "Save"

    expect(page).to have_text("0.0.1")

    visit routes.path(:firmwares)
    accept_prompt { click_button "Delete" }

    expect(page).to have_no_text("0.0.1")
  end

  it "deletes", :js do
    firmware
    visit routes.path(:firmwares)
    accept_prompt { click_button "Delete" }

    expect(page).to have_no_text(firmware.version)
  end
end

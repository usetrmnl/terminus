# frozen_string_literal: true

require "hanami_helper"

RSpec.describe "Devices", :db do
  using Refinements::Pathname

  let(:device) { Factory[:device, model_id: model.id] }
  let(:model) { Factory[:model, name: "og_plus"] }

  include_context "with temporary directory"

  it "creates", :aggregate_failures, :js do
    model
    visit routes.path(:devices)
    click_link "New"
    select model.label, from: "device[model_id]"
    fill_in "device[mac_address]", with: "Bogus!"
    click_button "Save"

    expect(page).to have_text("is in invalid format")

    fill_in "device[mac_address]", with: "AA:BB:CC:11:22:33"
    click_button "Save"
    click_link "View"

    expect(page).to have_text("AA:BB:CC:11:22:33")
  end

  it "edits", :aggregate_failures, :js do
    device
    other_model = Factory[:model, label: "Other Model"]

    visit routes.path(:devices)
    click_link "Edit"
    fill_in "device[label]", with: nil
    click_button "Save"

    expect(page).to have_text("must be filled")

    select other_model.label, from: "device[model_id]"
    fill_in "device[label]", with: "Edit Test"
    click_button "Save"

    expect(page).to have_text("Other Model")
    expect(page).to have_text("Edit Test")
  end

  it "deletes", :js do
    device
    visit routes.path(:devices)
    accept_prompt { click_button "Delete" }

    expect(page).to have_no_text(device.label)
  end

  it "imports attachment", :aggregate_failures do
    model
    Factory[:playlist, name: "test"]

    path = SPEC_ROOT.join "support/fixtures/devices.csv"

    visit routes.path(:devices)
    click_button "Bulk upload"
    click_button "Import"

    expect(page).to have_text("must be filled")

    within ".bit-popover-content", text: "Import" do
      attach_file "devices_attachment", temp_dir.join("bad.csv").write("Bogus\nbogus")
    end

    click_button "Import"

    expect(page).to have_text("rows.0.model_name is missing.")

    click_button "Bulk upload"

    within ".bit-popover-content", text: "Import" do
      attach_file "devices_attachment", path
    end

    click_button "Import"

    expect(page).to have_text("Devices imported!")
  end

  it "imports URI", :aggregate_failures do
    model

    valid_uri = "https://gist.githubusercontent.com/bkuhlmann/7a924a2b083a6c2f85a6babd6e9c2981" \
                "/raw/f924c6f6e15c2f8eaee5d908f681ec7292c2e716/devices.csv"

    invalid_uri = "https://gist.githubusercontent.com/bkuhlmann/acf17fde75ec721c3e46b7724b94379a" \
                  "/raw/a7f89576340584068a49b9693ab512b0c6eda77c/gistfile1.txt"

    visit routes.path(:devices)
    click_button "Bulk upload"

    within ".bit-popover-content", text: "Import" do
      fill_in "devices_uri", with: "https://test.io/bogus"
    end

    click_button "Import"

    expect(page).to have_text("Unable to download file.")

    click_button "Bulk upload"

    within ".bit-popover-content", text: "Import" do
      fill_in "devices_uri", with: invalid_uri
    end

    click_button "Import"

    expect(page).to have_text("rows.0.model_name must be filled")

    click_button "Bulk upload"

    within ".bit-popover-content", text: "Import" do
      fill_in "devices_uri", with: valid_uri
    end

    click_button "Import"

    expect(page).to have_text("Devices imported!")
  end
end

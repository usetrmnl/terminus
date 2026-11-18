# frozen_string_literal: true

require "hanami_helper"

RSpec.describe "Models", :db do
  using Refinements::Pathname

  let(:model) { Factory[:model] }

  it "creates", :aggregate_failures, :js do
    visit routes.path(:models)
    click_link "New"
    fill_in "model[label]", with: "Test"

    click_button "Save"

    expect(page).to have_text("must be filled")

    fill_in "model[name]", with: "test"
    click_button "Save"

    expect(page).to have_text("Test")
  end

  it "edits", :aggregate_failures, :js do
    model
    visit routes.path(:models)
    click_link "Edit"
    fill_in "model[label]", with: nil
    click_button "Save"

    expect(page).to have_text("must be filled")

    fill_in "model[label]", with: "Edit Test"
    click_button "Save"

    expect(page).to have_text("Edit Test")
  end

  it "clones", :aggregate_failures, :js do
    Factory[:model, name: "test"]
    visit routes.path(:models)
    click_link "Clone"
    fill_in "model[name]", with: nil
    click_button "Save"

    expect(page).to have_text("must be filled")

    fill_in "model[name]", with: "test"
    click_button "Save"

    expect(page).to have_text("must be unique")

    fill_in "model[label]", with: "Clone Test"
    fill_in "model[name]", with: "clone_test"
    click_button "Save"

    expect(page).to have_text("Clone Test")
  end

  it "imports", :js do
    exporter = Terminus::Aspects::Models::Exporter.new
    importer = Terminus::Aspects::Models::Importer.new
    model = Factory.structs[:model, name: "test", label: "Import Test", colors: 2, bit_depth: 1]
    path = exporter.call(model).bind { |io| temp_dir.join("test.zip").write io.read }

    path.open { importer.call it }

    visit routes.path(:models)
    click_button "Upload"

    within ".bit-popover-content", text: "Import" do
      attach_file "model_attachment", path
      click_button "Submit"
    end

    expect(page).to have_text("Import Test")
  end

  it "exports" do
    model

    visit routes.path(:models)
    within ".bit-card", text: model.label do
      click_link "Download"
    end

    expect(page.source.encoding).to eq(Encoding::ASCII_8BIT)
  end

  it "deletes", :js do
    model
    visit routes.path(:models)

    within ".bit-card", text: model.label do
      accept_prompt { click_button "Delete" }
    end

    expect(page).to have_no_text(model.label)
  end
end

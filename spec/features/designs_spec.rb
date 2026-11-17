# frozen_string_literal: true

require "hanami_helper"

RSpec.describe "Designs", :db do
  using Refinements::Pathname

  let(:model) { Factory[:model] }
  let(:template) { Factory[:screen_template, name: "original", label: "Original"] }

  before { template }

  it "views index" do
    visit routes.path(:designs)
    expect(page).to have_text(template.label)
  end

  it "creates", :js do
    model
    visit routes.path(:designs)
    click_link "New"
    select model.label, from: "model_id"
    fill_in "design[label]", with: "Test"
    fill_in "design[name]", with: "test"
    click_button "Save"

    expect(page).to have_text("Edit Design")
  end

  it "edits", :js do
    visit routes.path(:design_edit, id: template.id)
    expect(page).to have_text("Edit Design")
  end

  it "clones", :aggregate_failures, :js do
    model
    visit routes.path(:designs)
    click_link "Clone"
    select model.label, from: "model_id"
    fill_in "design[name]", with: nil
    click_button "Save"

    expect(page).to have_text("must be filled")

    fill_in "design[name]", with: "original"
    select model.label, from: "model_id"
    click_button "Save"

    expect(page).to have_text("must be unique")

    fill_in "design[label]", with: "Clone Test"
    fill_in "design[name]", with: "clone_test"
    select model.label, from: "model_id"
    click_button "Save"

    expect(page).to have_text("Clone Test")
  end

  it "imports", :aggregate_failures, :js do
    model
    exporter = Terminus::Aspects::Designs::Exporter.new
    importer = Terminus::Aspects::Designs::Importer.new
    screen_template = Factory.structs[:screen_template, label: "Design Import Test"]
    path = exporter.call(screen_template).bind { |io| temp_dir.join("test.zip").write io.read }

    path.open { importer.call it }

    visit routes.path(:designs)
    click_button "Upload"

    within ".bit-popover-content", text: "Import" do
      select model.label, from: "model_id"
      attach_file "design_attachment", path
      click_button "Submit"
    end

    expect(page).to have_text("Design Import Test")
  end

  it "exports" do
    visit routes.path(:designs)
    click_link "Download"

    expect(page.source.encoding).to eq(Encoding::ASCII_8BIT)
  end

  it "deletes", :js do
    visit routes.path(:designs)
    accept_prompt { click_button "Delete" }

    expect(page).to have_no_text(template.label)
  end
end

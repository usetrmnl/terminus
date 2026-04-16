# frozen_string_literal: true

require "hanami_helper"

RSpec.describe "Extensions", :db do
  let(:model) { Factory[:model, name: "og_plus"] }
  let(:extension) { Factory[:extension] }

  it "creates", :aggregate_failures, :js do
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

  it "edits", :aggregate_failures, :js do
    model
    extension

    visit routes.path(:extension_edit, id: extension.id)
    fill_in "extension[label]", with: nil
    click_button "Save"

    expect(page).to have_content("must be filled")

    fill_in "extension[label]", with: "Edit Test"
    click_button "Save"

    expect(page).to have_content("Changes saved.")
    expect(page).to have_field(with: "Edit Test")
  end

  it "views exchanges" do
    model
    exchange = Factory[:extension_exchange, extension_id: extension.id]
    visit routes.path(:extension_edit, id: extension.id)
    click_link "Exchanges"

    expect(page).to have_content(exchange.template)
  end

  it "builds", :js do
    model
    extension
    visit routes.path(:extension_edit, id: extension.id)
    click_button "Build"

    expect(page).to have_content("Enqueuing...")
  end

  it "clones", :aggregate_failures, :js do
    model
    extension

    visit routes.path(:extensions)
    click_link "Clone"
    fill_in "extension[label]", with: nil
    click_button "Save"

    expect(page).to have_content("must be filled")

    fill_in "extension[label]", with: "Clone Test"
    click_button "Save"

    expect(page).to have_content("Clone Test")
  end

  it "deletes", :js do
    extension
    visit routes.path(:extensions)

    within ".bit-card", text: extension.label do
      accept_prompt { click_button "Delete" }
    end

    expect(page).to have_no_content(extension.label)
  end

  it "views gallery", :aggregate_failures do
    Hanami.app.start :trmnl_api
    visit routes.path(:extensions_gallery)

    expect(page).to have_content("Gallery")
    expect(page).to have_content("connection")
  end
end

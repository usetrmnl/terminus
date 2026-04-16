# frozen_string_literal: true

require "hanami_helper"

RSpec.describe "Extension Exchanges", :db do
  let(:extension) { Factory[:extension] }
  let(:exchange) { Factory[:extension_exchange, extension_id: extension.id] }

  it "creates", :aggregate_failures do
    visit routes.path(:extension_exchanges, extension_id: extension.id)
    click_link "New"
    click_button "Save"

    expect(page).to have_content("must be filled")

    fill_in "exchange[template]", with: "https://test.io"
    click_button "Save"

    expect(page).to have_content("https://test.io")
  end

  it "edits", :aggregate_failures, :js do
    visit routes.path(:extension_exchange_edit, extension_id: extension.id, id: exchange.id)
    fill_in "exchange[template]", with: nil
    click_button "Save"

    expect(page).to have_content("must be filled")

    fill_in "exchange[template]", with: "https://test.io/1"

    expect(page).to have_field(with: "https://test.io/1")
  end

  it "deletes", :js do
    exchange
    visit routes.path(:extension_exchanges, extension_id: extension.id)

    within "td.bit-actions", text: extension.template do
      accept_prompt { click_button "Delete" }
    end

    expect(page).to have_no_content(exchange.template)
  end
end

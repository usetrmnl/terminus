# frozen_string_literal: true

require "hanami_helper"

RSpec.describe "Dashboard", :db do
  it "lists IP addresses" do
    visit routes.path(:root)
    expect(page).to have_css("li", text: /\d+\.\d+\.\d+/)
  end

  it "lists firmware" do
    firmware = Factory[:firmware]
    visit routes.path(:root)

    expect(page).to have_link(
      "0.0.0",
      href: Hanami.app[:routes].path(:firmware_show, id: firmware.id)
    )
  end

  it "renders dashboard when firmware is missing" do
    visit routes.path(:root)
    expect(page).to have_content("Dashboard")
  end

  it "shows linked resource counts", :aggregate_failures do
    visit routes.path(:root)

    expect(page).to have_link("0", href: routes.path(:devices))
    expect(page).to have_link("0", href: routes.path(:extensions))
    expect(page).to have_link("0", href: routes.path(:models))
    expect(page).to have_link("0", href: routes.path(:playlists))
    expect(page).to have_link("0", href: routes.path(:screens))
    expect(page).to have_link("1", href: routes.path(:users))
  end
end

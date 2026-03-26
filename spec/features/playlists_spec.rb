# frozen_string_literal: true

require "hanami_helper"

RSpec.describe "Playlists", :db do
  let(:playlist) { Factory[:playlist] }

  it "creates, edits, saves, clones, and deletes playlist", :aggregate_failures, :js do
    visit routes.path(:playlists)
    click_link "New"
    fill_in "playlist[label]", with: "Test"

    click_button "Save"

    expect(page).to have_content("must be filled")

    fill_in "playlist[name]", with: "test"
    click_button "Save"

    expect(page).to have_content("Test")

    click_link "Edit"
    fill_in "playlist[label]", with: nil
    click_button "Save"

    expect(page).to have_content("must be filled")

    fill_in "playlist[label]", with: "Test II"
    click_button "Save"

    expect(page).to have_content("Test II")

    visit routes.path(:playlists)
    click_link "Clone"
    fill_in "playlist[name]", with: nil
    click_button "Save"

    expect(page).to have_content("must be filled")

    fill_in "Name", with: "test"
    click_button "Save"

    expect(page).to have_content("must be unique")

    fill_in "playlist[name]", with: "test_clone"
    click_button "Save"

    expect(page).to have_content("Test II Clone")

    visit routes.path(:playlists)

    within ".bit-card", text: "Test II Clone" do
      accept_prompt { click_button "Delete" }
    end

    expect(page).to have_no_content("Test II Clone")
  end

  it "plays screens", :aggregate_failures, :js do
    visit routes.path(:playlist_screens, playlist_id: playlist.id)

    expect(page).to have_content("No screens found.")

    items = (1..3).map do |position|
      Factory[
        :playlist_item,
        playlist_id: playlist.id,
        screen_id: Factory[:screen, :with_image].id,
        position:
      ]
    end

    Terminus::Repositories::Playlist.new.update playlist.id, current_item_id: items.first.id

    visit routes.path(:playlists)
    click_link "Play"

    expect(page).to have_content(playlist.label)
    expect(page).to have_css(%(#progress[aria-label="Slide 1 of 3"]))
    expect(page).to have_css(%(#progress[value="0"]))
    expect(page).to have_css(%(#progress[max="2"]))

    click_link "Next"

    expect(page).to have_css(%(#progress[aria-label="Slide 2 of 3"]))
    expect(page).to have_css(%(#progress[value="1"]))

    click_link "Next"

    expect(page).to have_css(%(#progress[aria-label="Slide 3 of 3"]))
    expect(page).to have_css(%(#progress[value="2"]))

    click_link "Previous"

    expect(page).to have_css(%(#progress[aria-label="Slide 2 of 3"]))
    expect(page).to have_css(%(#progress[value="1"]))
  end

  it "mirrors playlist to device", :aggregate_failures, :js do
    device = Factory[:device]
    playlist

    visit routes.path(:playlists)
    click_link "Mirror"
    check device.label
    click_button "Save"

    expect(page).to have_content(playlist.label)

    click_link "Mirror"
    click_link "Cancel"

    expect(page).to have_content(playlist.label)
  end
end

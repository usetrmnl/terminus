# frozen_string_literal: true

require "hanami_helper"

RSpec.describe "Playlists", :db do
  let(:playlist) { Factory[:playlist] }

  it "creates", :aggregate_failures, :js do
    visit routes.path(:playlists)
    click_link "New"
    fill_in "playlist[label]", with: "Test"

    click_button "Save"

    expect(page).to have_text("must be filled")

    fill_in "playlist[name]", with: "test"
    click_button "Save"

    expect(page).to have_text("Test")
  end

  it "edits", :aggregate_failures, :js do
    playlist
    visit routes.path(:playlists)
    click_link "Edit"
    fill_in "playlist[label]", with: nil
    click_button "Save"

    expect(page).to have_text("must be filled")

    fill_in "playlist[label]", with: "Edit Playlist"
    click_button "Save"

    expect(page).to have_text("Edit Playlist")
  end

  it "clones", :aggregate_failures, :js do
    Factory[:playlist, name: "test"]
    visit routes.path(:playlists)
    click_link "Clone"
    fill_in "playlist[name]", with: nil
    click_button "Save"

    expect(page).to have_text("must be filled")

    fill_in "playlist[name]", with: "test"
    click_button "Save"

    expect(page).to have_text("must be unique")

    fill_in "playlist[label]", with: "Clone Test"
    fill_in "playlist[name]", with: "clone_test"
    click_button "Save"

    expect(page).to have_text("Clone Test")
  end

  it "deletes", :js do
    playlist
    visit routes.path(:playlists)

    within ".bit-card", text: playlist.label do
      accept_prompt { click_button "Delete" }
    end

    expect(page).to have_no_text(playlist.label)
  end

  it "shows and edits items", :aggregate_failures, :js do
    screen = Factory[:screen, :with_image]
    Factory[:playlist_item, playlist_id: playlist.id, screen_id: screen.id]
    visit routes.path(:playlist, id: playlist.id)

    expect(page).to have_css(%(img[src^="memory://"]))

    visit routes.path(:playlist_edit, id: playlist.id)

    expect(page).to have_text("Loading items...")
  end

  it "plays screenshow", :aggregate_failures, :js do
    visit routes.path(:playlist_screens, playlist_id: playlist.id)

    expect(page).to have_text("No screens found.")

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

    expect(page).to have_text(playlist.label)
    expect(page).to have_css(%(#progress[value="0"]))
    expect(page).to have_css(%(#progress[max="2"]))
    expect(page).to have_text("1 of 3")

    click_link "Next"

    expect(page).to have_css(%(#progress[value="1"]))
    expect(page).to have_text("2 of 3")

    click_link "Next"

    expect(page).to have_css(%(#progress[value="2"]))
    expect(page).to have_text("3 of 3")

    click_link "Previous"

    expect(page).to have_css(%(#progress[value="1"]))
    expect(page).to have_text("2 of 3")

    click_link "First"

    expect(page).to have_css(%(#progress[value="0"]))
    expect(page).to have_text("1 of 3")

    click_link "Last"

    expect(page).to have_css(%(#progress[value="2"]))
    expect(page).to have_text("3 of 3")
  end

  it "mirrors to device", :aggregate_failures, :js do
    device = Factory[:device]
    playlist

    visit routes.path(:playlists)
    click_link "Mirror"
    check device.label
    click_button "Save"

    expect(page).to have_text(playlist.label)

    click_link "Mirror"
    click_link "Cancel"

    expect(page).to have_text(playlist.label)
  end
end

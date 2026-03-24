# frozen_string_literal: true

require "hanami_helper"

RSpec.describe Terminus::Repositories::Playlist, :db do
  subject(:repository) { described_class.new }

  let(:playlist) { Factory[:playlist] }
  let(:item_repository) { Terminus::Repositories::PlaylistItem.new }

  describe "#all" do
    it "answers all records by created date/time" do
      playlist
      expect(repository.all.map(&:id)).to contain_exactly(playlist.id)
    end

    it "answers empty array when records don't exist" do
      expect(repository.all).to eq([])
    end
  end

  describe "#create_with_items" do
    let(:screen) { Factory[:screen] }
    let(:items) { [{screen_id: screen.id}] }

    it "answers record" do
      playlist = repository.create_with_items({name: "test", label: "Test"}, items)
      expect(playlist).to have_attributes(name: "test", label: "Test")
    end

    it "creates associations" do
      playlist = repository.create_with_items({name: "test", label: "Test"}, items)

      expect(item_repository.all).to include(
        having_attributes(playlist_id: playlist.id, screen_id: screen.id, position: 1)
      )
    end

    it "assigns current item ID when there are items" do
      playlist = repository.create_with_items({name: "test", label: "Test"}, items)
      item = item_repository.all.first

      expect(playlist.current_item_id).to eq(item.id)
    end

    it "doesn't create record when IDs are invalid" do
      repository.create_with_items({name: "test", label: "Test"}, [{screen_id: 666}])
    rescue ROM::SQL::ForeignKeyConstraintError
      expect(repository.all).to eq([])
    end

    it "doesn't associations when IDs are invalid" do
      repository.create_with_items({name: "test", label: "Test"}, [{screen_id: 666}])
    rescue ROM::SQL::ForeignKeyConstraintError
      expect(item_repository.all).to eq([])
    end
  end

  describe "#find" do
    it "answers record by ID" do
      expect(repository.find(playlist.id)).to have_attributes(playlist.to_h)
    end

    it "answers nil for unknown ID" do
      expect(repository.find(666)).to be(nil)
    end

    it "answers nil for nil ID" do
      expect(repository.find(nil)).to be(nil)
    end
  end

  describe "#find_by" do
    it "answers record when found by single attribute" do
      expect(repository.find_by(name: playlist.name)).to have_attributes(playlist.to_h)
    end

    it "answers record when found by multiple attributes" do
      expect(repository.find_by(name: playlist.name, label: playlist.label)).to have_attributes(
        playlist.to_h
      )
    end

    it "answers nil when not found" do
      expect(repository.find_by(name: "bogus")).to be(nil)
    end

    it "answers nil for nil" do
      expect(repository.find_by(name: nil)).to be(nil)
    end
  end

  describe "#search" do
    let(:playlist) { Factory[:playlist, label: "Test"] }

    before { playlist }

    it "answers records for case insensitive value" do
      expect(repository.search(:label, "test")).to contain_exactly(have_attributes(label: "Test"))
    end

    it "answers records for partial value" do
      expect(repository.search(:label, "te")).to contain_exactly(have_attributes(label: "Test"))
    end

    it "answers empty array for invalid value" do
      expect(repository.search(:label, "bogus")).to eq([])
    end
  end

  describe "#update_current_item" do
    it "updates current item when item exists" do
      playlist = Factory[:playlist]
      item = Factory[:playlist_item]
      update = repository.update_current_item playlist, item

      expect(update).to have_attributes(current_item_id: item.id)
    end

    it "doesn't update current item is nil" do
      playlist = Factory[:playlist]
      update = repository.update_current_item playlist, nil

      expect(update.current_item_id).to be(nil)
    end
  end

  describe "#update_with_devices" do
    let(:screen) { Factory[:screen] }
    let(:items) { [{screen_id: screen.id}] }

    it "answers updated record" do
      update = repository.update_with_items playlist.id, {name: "test", label: "Test"}, items
      expect(update).to have_attributes(name: "test", label: "Test")
    end

    it "updates existing associations" do
      playlist = repository.create_with_items({name: "test", label: "Test"}, items)
      repository.update_with_items playlist.id, {}, [{screen_id: screen.id}]

      expect(item_repository.all).to include(
        having_attributes(playlist_id: playlist.id, screen_id: screen.id, position: 1)
      )
    end
  end

  describe "#update_with_items" do
    let(:screen) { Factory[:screen] }
    let(:items) { [{screen_id: screen.id}] }

    it "answers updated record" do
      update = repository.update_with_items playlist.id, {name: "test", label: "Test"}, items
      expect(update).to have_attributes(name: "test", label: "Test")
    end

    it "updates existing associations" do
      playlist = repository.create_with_items({name: "test", label: "Test"}, items)
      repository.update_with_items playlist.id, {}, [{screen_id: screen.id}, {screen_id: screen.id}]

      expect(item_repository.all).to include(
        having_attributes(playlist_id: playlist.id, screen_id: screen.id, position: 1),
        having_attributes(playlist_id: playlist.id, screen_id: screen.id, position: 2)
      )
    end

    it "updates removes items when empty" do
      playlist = repository.create_with_items({name: "test", label: "Test"}, items)
      repository.update_with_items playlist.id, {}, []

      expect(item_repository.all).to eq([])
    end

    it "doesn't removes associations when items are nil" do
      playlist = repository.create_with_items({name: "test", label: "Test"}, items)
      repository.update_with_items playlist.id, {}, nil

      expect(item_repository.all).to include(
        having_attributes(playlist_id: playlist.id, screen_id: screen.id, position: 1)
      )
    end
  end

  describe "#where" do
    it "answers record for single attribute" do
      expect(repository.where(label: playlist.label)).to contain_exactly(playlist)
    end

    it "answers record for multiple attributes" do
      expect(repository.where(label: playlist.label, name: playlist.name)).to contain_exactly(
        playlist
      )
    end

    it "answers empty array for unknown value" do
      expect(repository.where(label: "bogus")).to eq([])
    end

    it "answers empty array for nil" do
      expect(repository.where(label: nil)).to eq([])
    end
  end

  describe "#with_items" do
    it "answers items ordered by position" do
      one = Factory[:playlist_item, playlist_id: playlist.id, position: 2]
      two = Factory[:playlist_item, playlist_id: playlist.id, position: 1]
      update = repository.with_items.by_pk(playlist.id).one

      expect(update.playlist_items.map(&:id)).to eq([two.id, one.id])
    end
  end

  describe "#with_screens" do
    it "answers associated screens" do
      screen = Factory[:screen, label: "Association Test"]
      item = Factory[:playlist_item, screen:]
      playlist = repository.with_screens.by_pk(item.playlist_id).one

      expect(playlist.screens.map(&:label)).to contain_exactly("Association Test")
    end
  end
end

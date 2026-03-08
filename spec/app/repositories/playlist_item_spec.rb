# frozen_string_literal: true

require "hanami_helper"

RSpec.describe Terminus::Repositories::PlaylistItem, :db do
  subject(:repository) { described_class.new }

  let(:playlist_item) { Factory[:playlist_item] }

  describe "#all" do
    it "answers all records by created date/time" do
      playlist_item
      two = Factory[:playlist_item]

      expect(repository.all).to eq([playlist_item, two])
    end

    it "answers empty array when records don't exist" do
      expect(repository.all).to eq([])
    end
  end

  describe "#create_with_position" do
    let(:playlist) { Factory[:playlist] }
    let(:screen) { Factory[:screen] }

    it "answers item with position" do
      repository.create_with_position playlist_id: playlist.id, screen_id: screen.id
      item = repository.create_with_position playlist_id: playlist.id, screen_id: screen.id

      expect(item).to have_attributes(
        playlist_id: playlist.id,
        screen_id: screen.id,
        position: 2,
        playlist: kind_of(Terminus::Structs::Playlist),
        screen: kind_of(Terminus::Structs::Screen)
      )
    end
  end

  describe "#delete_all" do
    it "deletes records with specific attributes" do
      playlist_item
      Factory[:playlist_item, repeat_type: "minute"]
      repository.delete_all repeat_type: "minute"

      expect(repository.all).to contain_exactly(playlist_item)
    end

    it "answers number of records deleted" do
      playlist_item
      expect(repository.delete_all).to eq(1)
    end

    it "answers zero when there is nothing to delete" do
      expect(repository.delete_all).to eq(0)
    end
  end

  describe "#find" do
    it "answers record by ID" do
      expect(repository.find(playlist_item.id)).to eq(playlist_item)
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
      expect(repository.find_by(playlist_id: playlist_item.playlist_id)).to eq(playlist_item)
    end

    it "answers record when found by multiple attributes" do
      result = repository.find_by playlist_id: playlist_item.playlist_id,
                                  screen_id: playlist_item.screen_id

      expect(result).to eq(playlist_item)
    end

    it "answers nil when not found" do
      expect(repository.find_by(playlist_id: 666)).to be(nil)
    end

    it "answers nil for nil" do
      expect(repository.find_by(playlist_id: nil)).to be(nil)
    end
  end

  describe "#next_item" do
    it "answers next item" do
      playlist_id = Factory[:playlist].id
      one = Factory[:playlist_item, playlist_id:, position: 1]
      two = Factory[:playlist_item, playlist_id:, position: 2]

      expect(repository.next_item(after: one.position, playlist_id:)).to have_attributes(
        position: two.position,
        screen: kind_of(Terminus::Structs::Screen)
      )
    end
  end

  describe "#where" do
    it "answers record for single attribute" do
      result = repository.where playlist_id: playlist_item.playlist_id
      expect(result).to contain_exactly(playlist_item)
    end

    it "answers record for multiple attributes" do
      result = repository.where playlist_id: playlist_item.playlist_id,
                                screen_id: playlist_item.screen_id

      expect(result).to contain_exactly(playlist_item)
    end

    it "answers empty array for unknown value" do
      expect(repository.where(playlist_id: 666)).to eq([])
    end

    it "answers empty array for nil" do
      expect(repository.where(playlist_id: nil)).to eq([])
    end
  end
end

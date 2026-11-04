# frozen_string_literal: true

require "hanami_helper"

RSpec.describe Terminus::Aspects::Screens::Importer, :db do
  using Refinements::Pathname

  subject(:importer) { described_class.new }

  include_context "with application dependencies"
  include_context "with temporary directory"

  describe "#call" do
    let(:model) { Factory[:model, name: "og_bwry"] }
    let(:test_path) { temp_dir.join "Test.png" }

    let :meta do
      temp_dir.join("meta.yml").write <<~CONTENT
        attributes:
          model:
            name: og_bwry
          playlist:
            name: test
            label: Test
          screen:
            mode: dither
      CONTENT
    end

    before do
      meta
      SPEC_ROOT.join("support/fixtures/test.png").copy test_path
    end

    it "creates playlist when missing" do
      repository = Terminus::Repositories::Playlist.new

      importer.call temp_dir

      expect(repository.find_by(name: "test")).to have_attributes(name: "test", label: "Test")
    end

    it "uses existing playlist when name matches" do
      Factory[:playlist, name: "test", label: "Existing"]

      repository = Terminus::Repositories::Playlist.new

      importer.call temp_dir

      expect(repository.find_by(name: "test")).to have_attributes(name: "test", label: "Existing")
    end

    it "deletes exiting playlist items" do
      playlist = Factory[:playlist, name: "test", label: "Existing"]
      item = Factory[:playlist_item, playlist_id: playlist.id]
      repository = Terminus::Repositories::PlaylistItem.new

      importer.call temp_dir

      expect(repository.find(item.id)).to be(nil)
    end

    it "adds screen to playlist items" do
      model
      playlist_repository = Terminus::Repositories::Playlist.new
      item_repository = Terminus::Repositories::PlaylistItem.new

      importer.call temp_dir

      playlist = playlist_repository.find_by name: "test"
      items = item_repository.where playlist_id: playlist.id

      expect(items).to match(
        [
          having_attributes(screen: having_attributes(name: "test", label: "Test"))
        ]
      )
    end

    it "updates playlist's current item with first item" do
      model
      Factory[:playlist, name: "test"]

      playlist_repository = Terminus::Repositories::Playlist.new
      item_repository = Terminus::Repositories::PlaylistItem.new

      importer.call temp_dir

      playlist = playlist_repository.find_by name: "test"

      expect(playlist.current_item_id).to eq(item_repository.first(playlist_id: playlist.id).id)
    end

    it "answers success with array of metadata" do
      model

      expect(importer.call(temp_dir)).to eq(
        [
          Metapath::Model[
            name: "test",
            path: test_path,
            label: "Test",
            attributes: {
              "playlist" => {
                "name" => "test",
                "label" => "Test"
              },
              "model" => {
                "name" => "og_bwry"
              },
              "screen" => {
                "mode" => "dither"
              }
            }
          ]
        ]
      )
    end

    it "answers failure when Metapath fails" do
      metapath = instance_double Metapath::Modeler, call: Failure("Danger!")
      importer = described_class.new(metapath:)
      importer.call temp_dir

      expect(logger.reread).to match("ERROR.+Danger!")
    end

    it "logs procesing information" do
      model
      importer.call temp_dir

      expect(logger.reread).to match(/INFO.+Upserted screen: Test \(\d+\)\./)
    end

    it "logs failure when model can't be found" do
      importer.call temp_dir
      expect(logger.reread).to match("ERROR.+Unknown model: og_bwry")
    end
  end
end

# frozen_string_literal: true

require "hanami_helper"

RSpec.describe Terminus::Repositories::Screen, :db do
  subject(:repository) { described_class.new }

  let(:screen) { Factory[:screen] }

  describe "#all" do
    it "answers all records" do
      screen
      expect(repository.all.map(&:id)).to contain_exactly(screen.id)
    end

    it "answers empty array when records don't exist" do
      expect(repository.all).to eq([])
    end
  end

  describe "#delete" do
    it "deletes existing record" do
      screen
      repository.delete screen.id

      expect(repository.all).to eq([])
    end

    it "deletes associated image" do
      instance = screen.upload SPEC_ROOT.join("support/fixtures/test.png").open
      repository.update screen.id, image_data: instance.image_attributes
      repository.delete screen.id

      expect(Hanami.app[:shrine].storages[:store].store).to eq({})
    end

    it "ignores unknown record" do
      repository.delete 13
      expect(repository.all).to eq([])
    end
  end

  describe "#find" do
    it "answers record by ID" do
      expect(repository.find(screen.id)).to eq(screen)
    end

    it "answers nil for unknown ID" do
      expect(repository.find(13)).to be(nil)
    end

    it "answers nil for nil ID" do
      expect(repository.find(nil)).to be(nil)
    end
  end

  describe "#find_by" do
    it "answers record when found" do
      expect(repository.find_by(name: screen.name)).to eq(screen)
    end

    it "answers record when found by multiple attributes" do
      expect(repository.find_by(name: screen.name, label: screen.label)).to eq(screen)
    end

    it "answers nil when not found" do
      expect(repository.find_by(name: "bogus")).to be(nil)
    end

    it "answers nil for nil" do
      expect(repository.find_by(name: nil)).to be(nil)
    end
  end

  describe "#search" do
    let(:screen) { Factory[:screen, label: "Test"] }

    before { screen }

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

  describe "#upsert_with_image" do
    let(:model) { Factory[:model] }

    let :mold do
      Terminus::Aspects::Screens::Mold[
        model_id: model.id,
        name: "test",
        label: "Test",
        content: "<p>test</p>",
        mime_type: "image/bmp"
      ]
    end

    let :proof do
      {
        model_id: model.id,
        name: "test",
        label: "Test",
        image_attributes: hash_including(
          metadata: hash_including(
            size: kind_of(Integer),
            width: 1,
            height: 1,
            filename: "test.bmp",
            mime_type: "image/bmp"
          )
        )
      }
    end

    context "when existing" do
      let(:struct) { Factory[:screen, :with_image, name: mold.name, model_id: model.id] }

      it "updates attributes" do
        path = SPEC_ROOT.join "support/fixtures/test.bmp"
        record = repository.upsert_with_image path, mold, struct

        expect(record).to have_attributes(proof)
      end
    end

    context "when not existing" do
      let(:struct) { Factory.structs[:screen, :with_image] }

      it "creates when not found" do
        path = SPEC_ROOT.join "support/fixtures/test.bmp"
        record = repository.upsert_with_image path, mold, struct

        expect(record).to have_attributes(proof)
      end
    end
  end

  describe "#where" do
    it "answers record for single attribute" do
      expect(repository.where(label: screen.label)).to contain_exactly(screen)
    end

    it "answers record for multiple attributes" do
      expect(repository.where(label: screen.label, name: screen.name)).to contain_exactly(screen)
    end

    it "answers empty array for unknown value" do
      expect(repository.where(label: "bogus")).to eq([])
    end

    it "answers empty array for nil" do
      expect(repository.where(label: nil)).to eq([])
    end
  end
end

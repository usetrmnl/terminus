# frozen_string_literal: true

require "hanami_helper"
require "trmnl/api"

RSpec.describe Terminus::Aspects::Models::Synchronizer, :db do
  subject(:synchronizer) { described_class.new trmnl_api: }

  let :trmnl_api do
    instance_double TRMNL::API::Client,
                    models: Success(
                      [
                        TRMNL::API::Models::Model[
                          name: "test",
                          label: "Test",
                          description: "A test.",
                          kind: "core",
                          colors: 3,
                          bit_depth: 5,
                          rotation: 90,
                          mime_type: "image/png",
                          width: 800,
                          height: 480,
                          offset_x: 10,
                          offset_y: 15,
                          palette_names: %w[bw gray-4],
                          css: {classes: {device: "screen-v2", size: "screen-lg"}}
                        ]
                      ]
                    )
  end

  let(:repository) { Terminus::Repositories::Model.new }
  let(:join_repository) { Terminus::Repositories::ModelPalette.new }

  describe "#call" do
    let(:palettes) { [Factory[:palette, name: "bw"], Factory[:palette, name: "gray-4"]] }

    context "with no remote models" do
      let(:trmnl_api) { instance_double TRMNL::API::Client, models: Success([]) }

      it "deletes BYOD records" do
        Factory[:model, name: "test", kind: "byod"]
        synchronizer.call
        repository.all

        expect(repository.all).to eq([])
      end

      it "deletes Kindle records" do
        Factory[:model, name: "test", kind: "kindle"]
        synchronizer.call
        repository.all

        expect(repository.all).to eq([])
      end

      it "deletes Tidbyt records" do
        Factory[:model, name: "test", kind: "tidbyt"]
        synchronizer.call
        repository.all

        expect(repository.all).to eq([])
      end

      it "deletes TRMNL records" do
        Factory[:model, name: "test", kind: "trmnl"]
        synchronizer.call
        repository.all

        expect(repository.all).to eq([])
      end
    end

    context "with missing model" do
      before do
        palettes
        synchronizer.call
      end

      it "creates new record" do
        record = repository.all.first

        expect(record).to have_attributes(
          name: "test",
          label: "Test",
          description: "A test.",
          kind: "core",
          colors: 3,
          bit_depth: 5,
          rotation: 90,
          mime_type: "image/png",
          width: 800,
          height: 480,
          offset_x: 10,
          offset_y: 15,
          css: {"classes" => {"device" => "screen-v2", "size" => "screen-lg"}}
        )
      end

      it "adds palettes" do
        palettes
        synchronizer.call

        record = repository.all.first
        associations = join_repository.where model_id: record.id, palette_id: palettes.map(&:id)

        expect(associations.size).to eq(2)
      end

      it "sets default palette" do
        synchronizer.call
        record = repository.all.first

        expect(record.default_palette_id).to eq(palettes.first.id)
      end
    end

    context "with existing record" do
      let(:model) { Factory[:model, name: "test", kind: "core"] }

      before { model }

      it "updates existing record" do
        synchronizer.call
        record = repository.all.first

        expect(record).to have_attributes(
          name: "test",
          label: "Test",
          description: "A test.",
          kind: "core",
          colors: 3,
          bit_depth: 5,
          rotation: 90,
          mime_type: "image/png",
          width: 800,
          height: 480,
          offset_x: 10,
          offset_y: 15,
          css: {"classes" => {"device" => "screen-v2", "size" => "screen-lg"}}
        )
      end

      it "adds palettes" do
        join_repository.create model_id: model.id, palette_id: palettes.first.id
        synchronizer.call

        record = repository.all.first
        associations = join_repository.where model_id: record.id, palette_id: palettes.map(&:id)

        expect(associations).to match(
          [
            having_attributes(model_id: model.id, palette_id: palettes.first.id),
            having_attributes(model_id: model.id, palette_id: palettes.last.id)
          ]
        )
      end

      it "doesn't duplicate existing palettes" do
        palettes.each { join_repository.create model_id: model.id, palette_id: it.id }
        synchronizer.call

        record = repository.all.first
        associations = join_repository.where model_id: record.id, palette_id: palettes.map(&:id)

        expect(associations.size).to eq(2)
      end

      it "sets default palette when nil" do
        join_repository.create model_id: model.id, palette_id: palettes.first.id
        synchronizer.call

        record = repository.all.first

        expect(record.default_palette_id).to eq(palettes.first.id)
      end

      it "doesn't set default palette when already set" do
        repository.update model.id, default_palette_id: palettes.first.id
        synchronizer.call

        record = repository.all.first

        expect(record.default_palette_id).to eq(palettes.first.id)
      end
    end

    it "answers failure when models can't be obtained" do
      trmnl_api = instance_spy TRMNL::API::Client, models: Failure("Danger!")
      synchronizer = described_class.new(trmnl_api:)

      expect(synchronizer.call).to be_failure("Danger!")
    end
  end
end

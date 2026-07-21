# frozen_string_literal: true

require "hanami_helper"

RSpec.describe Terminus::Jobs::Screens::Upsert, :db do
  subject(:job) { described_class.new }

  include_context "with application dependencies"

  describe "#perform" do
    let(:model) { Factory[:model] }
    let(:screen) { Factory[:screen, model_id: model.id, label: "First", name: "first"] }
    let(:repository) { Terminus::Repositories::Screen.new }

    it "creates screen" do
      job.perform model.id, name: "test", label: "Test", content: "<h1>Test</h1>"
      screen = repository.find_by name: "test"

      expect(screen).to have_attributes(
        model_id: model.id,
        name: "test",
        label: "Test",
        image_attributes: hash_including(
          id: kind_of(String),
          metadata: kind_of(Hash),
          storage: "store"
        )
      )
    end

    it "logs info for create" do
      job.perform model.id, name: "test", label: "Test", content: "<h1>Test</h1>"
      expect(logger.reread).to match(/INFO.+Enqueued upsert for screen ID: \d+\./)
    end

    it "updates screen" do
      screen
      job.perform model.id, name: "first", label: "Update", content: "<h1>Test</h1>"
      update = repository.find screen.id

      expect(update).to have_attributes(model_id: model.id, name: "first", label: "Update")
    end

    it "logs info for update" do
      screen
      job.perform model.id, name: "first", label: "Update", content: "<h1>Test</h1>"

      expect(logger.reread).to match(/INFO.+Enqueued upsert for screen ID: #{screen.id}\./)
    end

    it "logs error when unable to upsert" do
      job.perform nil
      expect(logger.reread).to match(/ERROR.+Invalid attributes/)
    end
  end
end

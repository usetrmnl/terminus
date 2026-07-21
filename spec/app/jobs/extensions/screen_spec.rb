# frozen_string_literal: true

require "hanami_helper"

RSpec.describe Terminus::Jobs::Extensions::Screen, :db do
  subject(:job) { described_class.new }

  include_context "with application dependencies"

  describe "#perform" do
    let :extension do
      Factory[
        :extension,
        name: "test",
        label: "Test",
        kind: "static",
        static_body: {"name" => "Test"},
        template: "<p>{{name}}</p>"
      ]
    end

    let(:model) { Factory[:model] }

    it "creates screen" do
      job.perform extension.id, model.id
      screen = Terminus::Repositories::Screen.new.find_by name: "extension-test"

      expect(screen).to have_attributes(
        name: "extension-test",
        label: "Extension Test",
        image_attributes: hash_including(
          id: kind_of(String),
          metadata: kind_of(Hash),
          storage: "store"
        )
      )
    end

    it "logs info when enqueued" do
      job.perform extension.id, model.id

      expect(logger.reread).to match(
        /INFO.+Enqueued screen upsert for extension ID: #{extension.id}./
      )
    end

    it "logs error when extension can't be found" do
      job.perform 666, model.id
      expect(logger.reread).to match(/ERROR.+Unable to find by extension ID: 666\./)
    end
  end
end

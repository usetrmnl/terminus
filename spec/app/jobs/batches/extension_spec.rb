# frozen_string_literal: true

require "hanami_helper"

RSpec.describe Terminus::Jobs::Batches::Extension, :db do
  subject(:job) { described_class.new }

  include_context "with application dependencies"

  describe "#perform" do
    let(:repository) { Terminus::Repositories::Extension.new }
    let(:extension) { Factory[:extension] }
    let(:model) { Factory[:model] }

    context "with models" do
      let(:model) { Factory[:model] }

      before { repository.update_with_models extension.id, {}, [model.id] }

      it "logs info when extension is found" do
        job.perform extension.id
        expect(logger.reread).to match(/INFO.+Enqueued jobs for extension: #{extension.id}\./)
      end

      it "logs error when extension can't be found" do
        job.perform 666
        expect(logger.reread).to match(/ERROR.+Unable to enqueue jobs for extension: 666\./)
      end
    end

    context "with devices" do
      let(:device) { Factory[:device] }

      before { repository.update_with_devices extension.id, {}, [device.id] }

      it "logs info when extension is found" do
        job.perform extension.id
        expect(logger.reread).to match(/INFO.+Enqueued jobs for extension: #{extension.id}\./)
      end

      it "logs error when extension can't be found" do
        job.perform 666
        expect(logger.reread).to match(/ERROR.+Unable to enqueue jobs for extension: 666\./)
      end
    end
  end
end

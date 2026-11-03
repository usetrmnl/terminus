# frozen_string_literal: true

require "hanami_helper"

RSpec.describe Terminus::Jobs::Attachments::StoreDelete do
  subject(:job) { described_class.new }

  include_context "with application dependencies"

  describe "#perform" do
    let(:shrine) { Hanami.app[:shrine] }

    it "updates screen" do
      id = shrine.upload(StringIO.new("test"), :store).id
      job.perform id

      expect(shrine.storages[:store].exists?(id)).to be(false)
    end

    it "logs deleted ID" do
      id = shrine.upload(StringIO.new("test"), :store).id
      job.perform id

      expect(logger.reread).to match(/DEBUG.+Deleted stored attachment: #{id}\./)
    end
  end
end

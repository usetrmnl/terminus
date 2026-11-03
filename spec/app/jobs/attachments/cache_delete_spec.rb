# frozen_string_literal: true

require "hanami_helper"

RSpec.describe Terminus::Jobs::Attachments::CacheDelete do
  subject(:job) { described_class.new }

  include_context "with application dependencies"

  describe "#perform" do
    let(:shrine) { Hanami.app[:shrine] }

    it "updates screen" do
      id = shrine.upload(StringIO.new("test"), :cache).id
      job.perform id

      expect(shrine.storages[:cache].exists?(id)).to be(false)
    end

    it "logs deleted ID" do
      id = shrine.upload(StringIO.new("test"), :cache).id
      job.perform id

      expect(logger.reread).to match(/DEBUG.+Deleted cached attachment: #{id}\./)
    end
  end
end

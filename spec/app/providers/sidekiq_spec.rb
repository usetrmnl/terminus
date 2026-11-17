# frozen_string_literal: true

require "hanami_helper"

RSpec.describe Terminus::Providers::Sidekiq, :db do
  using Refinements::Hash

  subject :provider do
    described_class.new provider_container:, target_container:, slice:, resolver: proc { sidekiq }
  end

  let(:provider_container) { Dry::Core::Container.new }
  let(:target_container) { Dry::Core::Container.new }
  let(:slice) { Hanami.app }
  let(:sidekiq) { class_spy Sidekiq }

  describe "#prepare" do
    it "answers false due to already being loaded" do
      expect(provider.prepare).to be(false)
    end
  end

  describe "#start" do
    it "configures server" do
      provider.start
      expect(sidekiq).to have_received(:configure_server)
    end

    it "configures client" do
      provider.start
      expect(sidekiq).to have_received(:configure_client)
    end
  end
end

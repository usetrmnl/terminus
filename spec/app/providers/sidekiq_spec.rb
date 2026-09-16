# frozen_string_literal: true

require "hanami_helper"

RSpec.describe Terminus::Providers::Sidekiq do
  using Refinements::Hash

  subject :provider do
    described_class.new provider_container:,
                        target_container:,
                        slice:,
                        resolver: proc { sidekiq },
                        extension_repository:
  end

  let(:provider_container) { Dry::Core::Container.new }
  let(:target_container) { Dry::Core::Container.new }
  let(:slice) { Hanami.app }
  let(:sidekiq) { class_spy Sidekiq }
  let(:extension_repository) { instance_double Terminus::Repositories::Extension }

  describe "#prepare" do
    it "answers false due to already being loaded" do
      expect(provider.prepare).to be(false)
    end
  end

  describe "#start" do
    before { allow(extension_repository).to receive(:all).and_return([]) }

    it "configures server" do
      provider.start
      expect(sidekiq).to have_received(:configure_server)
    end

    it "configures client" do
      provider.start
      expect(sidekiq).to have_received(:configure_client)
    end

    it "loads static schedules" do
      provider.start

      expect(sidekiq).to have_received(:set_schedule).with("sensor_synchronizer", kind_of(Hash))
    end

    it "loads extension schedules" do
      extension = Factory.structs[:extension, unit: "minute", interval: 1]

      allow(extension_repository).to receive(:all).and_return([extension])
      provider.start

      expect(sidekiq).to have_received(:set_schedule).with(*extension.to_schedule)
    end

    it "doesn't load extension schedules when empty" do
      extension = Factory.structs[:extension]

      allow(extension_repository).to receive(:all).and_return([extension])
      provider.start

      expect(sidekiq).not_to have_received(:set_schedule).with(*extension.to_schedule)
    end

    it "doesn't load extension schedules when configuration is identical" do
      extension = Factory.structs[:extension, unit: "minute", interval: 1]

      allow(sidekiq).to receive(:get_schedule).with(extension.screen_name).and_return(
        extension.to_schedule.last.stringify_keys
      )
      allow(extension_repository).to receive(:all).and_return([extension])

      provider.start

      expect(sidekiq).not_to have_received(:set_schedule).with(*extension.to_schedule)
    end
  end
end

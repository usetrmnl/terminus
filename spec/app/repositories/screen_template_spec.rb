# frozen_string_literal: true

require "hanami_helper"

RSpec.describe Terminus::Repositories::ScreenTemplate, :db do
  subject(:repository) { described_class.new }

  let(:template) { Factory[:screen_template] }

  describe "#all" do
    it "answers records" do
      template
      expect(repository.all).to contain_exactly(template)
    end

    it "answers empty array when records don't exist" do
      expect(repository.all).to eq([])
    end
  end

  describe "#all_by_device" do
    let(:other_template) { Factory[:screen_template, device:] }
    let(:device) { Factory[:device] }

    it "answers records" do
      template
      other_template

      expect(repository.all_by_device(device.id)).to contain_exactly(
        have_attributes(
          id: other_template.id,
          device_id: device.id
        )
      )
    end

    it "answers empty array when records don't exist" do
      template
      expect(repository.all_by_device(device.id)).to eq([])
    end
  end

  describe "#find" do
    it "answers record by ID" do
      expect(repository.find(template.id)).to eq(template)
    end

    it "answers nil for unknown ID" do
      expect(repository.find(13)).to be(nil)
    end

    it "answers nil for nil ID" do
      expect(repository.find(nil)).to be(nil)
    end
  end
end

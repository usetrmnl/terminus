# frozen_string_literal: true

require "hanami_helper"

RSpec.describe Terminus::Aspects::Extensions::Deleter, :db do
  subject(:deleter) { described_class.new }

  describe "#call" do
    let(:extension) { Factory[:extension, label: "Test", name: "test"] }
    let(:attributes) { {id: extension.id} }

    it "answers failure when extension can't be found" do
      attributes[:id] = 666
      expect(deleter.call(attributes)).to be_failure("Unable to find extension ID: 666.")
    end

    it "deletes extension" do
      expect(deleter.call(attributes).value!).to have_attributes(label: "Test", name: "test")
    end

    it "deletes job schedule" do
      schedule = instance_spy Terminus::Aspects::Jobs::Schedule
      deleter = described_class.new(schedule:)

      deleter.call attributes

      expect(schedule).to have_received(:delete).with("extension-test")
    end

    it "answers success with extension" do
      expect(deleter.call(attributes)).to match(Success(Terminus::Structs::Extension))
    end
  end
end

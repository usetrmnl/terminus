# frozen_string_literal: true

require "hanami_helper"

RSpec.describe Terminus::Contracts::Rules::Cron do
  subject(:contract) { simulation.new }

  let :simulation do
    implementation = described_class

    Class.new Dry::Validation::Contract do
      params do
        required(:extension).hash do
          optional(:interval).filled :integer
          optional(:unit).filled :string
        end
      end

      rule(extension: :interval, &implementation)
    end
  end

  describe "#call" do
    let(:attributes) { {extension: {interval: 5}} }

    context "when none" do
      before { attributes[:extension][:unit] = "none" }

      it "answers success" do
        result = contract.call attributes
        expect(result.success?).to be(true)
      end
    end

    context "when minute" do
      before { attributes[:extension][:unit] = "minute" }

      it "answers success with valid attributes" do
        result = contract.call attributes
        expect(result.success?).to be(true)
      end

      it "answers error beyond lower bound" do
        attributes[:extension][:interval] = -1
        result = contract.call attributes

        expect(result.errors.to_h).to eq(
          extension: {
            interval: ["invalid schedule for minute -1."]
          }
        )
      end

      it "answers error beyond upper bound" do
        attributes[:extension][:interval] = 60
        result = contract.call attributes

        expect(result.errors.to_h).to eq(
          extension: {
            interval: ["invalid schedule for minute 60."]
          }
        )
      end
    end

    context "when hour" do
      before { attributes[:extension][:unit] = "hour" }

      it "answers success with valid attributes" do
        result = contract.call attributes
        expect(result.success?).to be(true)
      end

      it "answers error beyond lower bound" do
        attributes[:extension][:interval] = -1
        result = contract.call attributes

        expect(result.errors.to_h).to eq(
          extension: {
            interval: ["invalid schedule for hour -1."]
          }
        )
      end

      it "answers error beyond upper bound" do
        attributes[:extension][:interval] = 24
        result = contract.call attributes

        expect(result.errors.to_h).to eq(
          extension: {
            interval: ["invalid schedule for hour 24."]
          }
        )
      end
    end

    context "when day" do
      before { attributes[:extension][:unit] = "day" }

      it "answers success with valid attributes" do
        result = contract.call attributes
        expect(result.success?).to be(true)
      end

      it "answers error beyond lower bound" do
        attributes[:extension][:interval] = 0
        result = contract.call attributes

        expect(result.errors.to_h).to eq(extension: {interval: ["invalid schedule for day 0."]})
      end

      it "answers error beyond upper bound" do
        attributes[:extension][:interval] = 32
        result = contract.call attributes

        expect(result.errors.to_h).to eq(
          extension: {
            interval: ["invalid schedule for day 32."]
          }
        )
      end
    end

    context "when week" do
      before { attributes[:extension][:unit] = "week" }

      it "answers success with valid attributes" do
        result = contract.call attributes
        expect(result.success?).to be(true)
      end

      it "answers error beyond lower bound" do
        attributes[:extension][:interval] = -1
        result = contract.call attributes

        expect(result.errors.to_h).to eq(
          extension: {
            interval: ["invalid schedule for week -1."]
          }
        )
      end

      it "answers error beyond upper bound" do
        attributes[:extension][:interval] = 7
        result = contract.call attributes

        expect(result.errors.to_h).to eq(
          extension: {
            interval: ["invalid schedule for week 7."]
          }
        )
      end
    end

    context "when month" do
      before { attributes[:extension][:unit] = "month" }

      it "answers success with valid attributes" do
        result = contract.call attributes
        expect(result.success?).to be(true)
      end

      it "answers error beyond lower bound" do
        attributes[:extension][:interval] = -1
        result = contract.call attributes

        expect(result.errors.to_h).to eq(
          extension: {
            interval: ["invalid schedule for month -1."]
          }
        )
      end

      it "answers error beyond upper bound" do
        attributes[:extension][:interval] = 13
        result = contract.call attributes

        expect(result.errors.to_h).to eq(
          extension: {
            interval: ["invalid schedule for month 13."]
          }
        )
      end
    end
  end
end

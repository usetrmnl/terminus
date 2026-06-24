# frozen_string_literal: true

require "hanami_helper"

RSpec.describe Terminus::Types do
  describe "File" do
    subject(:type) { described_class::File }

    let(:path) { File.new SPEC_ROOT.join("support/fixtures/sensors.json") }

    it "answers valid file" do
      expect(type.call(path)).to eq(path)
    end

    it "answers valid tempfile" do
      path = Tempfile.new
      expect(type.call(path)).to eq(path)
    ensure
      path.close
      path.unlink
    end

    it "answers valid String IO" do
      io = StringIO.new
      expect(type.call(io)).to eq(io)
    end

    it "fails when object can't be coerced" do
      expectation = proc { type.call nil }
      expect(&expectation).to raise_error(Dry::Types::CoercionError, /nil violates constraints/)
    end
  end

  describe "Pathname" do
    subject(:type) { described_class::Pathname }

    it "answers primitive" do
      expect(type.primitive).to eq(Pathname)
    end

    it "answers valid pathname" do
      expect(type.call("a/b/c")).to eq(Pathname("a/b/c"))
    end

    it "fails when object can't be coerced" do
      expectation = proc { type.call nil }
      expect(&expectation).to raise_error(Dry::Types::CoercionError, /requires a String/)
    end
  end

  describe "MACAddress" do
    subject(:type) { described_class::MACAddress }

    it "answers primitive" do
      expect(type.primitive).to eq(String)
    end

    it "answers valid string" do
      expect(type.call("A1:B2:C3:D4:E5:F6")).to eq("A1:B2:C3:D4:E5:F6")
    end

    it "fails with too few segments" do
      expectation = proc { type.call "A1:B2:C3" }
      expect(&expectation).to raise_error(Dry::Types::ConstraintError, /violates constraints/)
    end

    it "fails with too many segments" do
      expectation = proc { type.call "A1:B2:C3:D4:E5:F6:G7" }
      expect(&expectation).to raise_error(Dry::Types::ConstraintError, /violates constraints/)
    end

    it "fails when lowercase" do
      expectation = proc { type.call "a1:b2:c3:d4:e5:f6" }
      expect(&expectation).to raise_error(Dry::Types::ConstraintError, /violates constraints/)
    end

    it "fails with no colons" do
      expectation = proc { type.call "A1B2C3D4E5F6" }
      expect(&expectation).to raise_error(Dry::Types::ConstraintError, /violates constraints/)
    end
  end

  describe "Version" do
    subject(:type) { described_class::Version }

    it "answers primitive" do
      expect(type.primitive).to eq(String)
    end

    it "answers valid single digit version" do
      expect(type.call("0.0.0")).to eq("0.0.0")
    end

    it "answers valid multiple digit version" do
      expect(type.call("1.10.100")).to eq("1.10.100")
    end

    it "answers coerces partial version into full version" do
      expectation = proc { type.call "1.2" }
      expect(&expectation).to raise_error(Dry::Types::ConstraintError, /violates constraints/)
    end
  end
end

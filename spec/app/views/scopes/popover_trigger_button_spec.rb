# frozen_string_literal: true

require "hanami_helper"

RSpec.describe Terminus::Views::Scopes::PopoverTriggerButton do
  subject(:scope) { described_class.new locals:, rendering: Terminus::View.new.rendering }

  let(:locals) { {icon: :info} }

  describe "#classes" do
    it "answers default classes" do
      expect(scope.classes).to eq("bit-popover-trigger")
    end

    it "answers custom classes" do
      locals[:classes] = "one two three"
      expect(scope.classes).to eq("one two three")
    end
  end

  describe "#height" do
    it "answers default height" do
      expect(scope.height).to eq(15)
    end

    it "answers custom height" do
      locals[:height] = 30
      expect(scope.height).to eq(30)
    end
  end

  describe "#icon" do
    it "answers default icon" do
      expect(scope.icon).to eq(:info)
    end

    it "answers custom icon" do
      locals[:icon] = :test
      expect(scope.icon).to eq(:test)
    end
  end

  describe "#icon_uri" do
    it "answers default URI" do
      expect(scope.icon_uri).to eq("icons/info.svg")
    end

    it "answers custom URI" do
      locals[:icon] = :test
      expect(scope.icon_uri).to eq("icons/test.svg")
    end
  end

  describe "#render" do
    it "renders button" do
      expect(scope.render).to include(%(<button type="button" class="bit-popover-trigger">))
    end

    it "renders image" do
      expect(scope.render).to match(%r(assets/icons/info.*.svg))
    end

    it "renders with yielded content" do
      content = scope.render { "A test." }
      expect(content).to include("A test.")
    end

    it "renders with tip and target" do
      locals.merge! tip: :test, target: :test

      expect(scope.render).to include(
        %(<button type="button" class="bit-popover-trigger" interestfor="tooltip-action-test" ) +
        %(popovertarget="popover-test">)
      )
    end
  end

  describe "#target" do
    it "answers nil when not set" do
      expect(scope.target).to be(nil)
    end

    it "answers target when set" do
      locals[:target] = :test
      expect(scope.target).to eq("popover-test")
    end
  end

  describe "#tip" do
    it "answers nil when not set" do
      expect(scope.tip).to be(nil)
    end

    it "answers tip when set" do
      locals[:tip] = :test
      expect(scope.tip).to eq("tooltip-action-test")
    end
  end

  describe "#width" do
    it "answers default height" do
      expect(scope.width).to eq(15)
    end

    it "answers custom height" do
      locals[:width] = 30
      expect(scope.width).to eq(30)
    end
  end
end

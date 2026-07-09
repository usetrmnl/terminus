# frozen_string_literal: true

require "hanami_helper"

RSpec.describe Terminus::Views::Scopes::TooltipActionContent do
  using Refinements::Hash

  subject(:scope) { described_class.new locals:, rendering: Terminus::View.new.rendering }

  let(:locals) { {label: "Test"} }

  describe "#element_id" do
    it "answers prefix with downcased label" do
      expect(scope.element_id).to eq("tooltip-action-test")
    end

    it "answers custom name when provided" do
      locals[:id] = "alternative"
      expect(scope.element_id).to eq("tooltip-action-alternative")
    end

    it "fails when label is missing" do
      locals.delete :label
      expectation = proc { scope.element_id }

      expect(&expectation).to raise_error(NameError, /label/)
    end
  end

  describe "#classes" do
    it "answers default classes" do
      expect(scope.classes).to eq("bit-tooltip-action")
    end

    it "answers custom classes" do
      locals[:classes] = "one two"
      expect(scope.classes).to eq("one two")
    end
  end

  describe "#render" do
    it "renders content" do
      expect(scope.render).to eq(<<~CONTENT)
        <div id="tooltip-action-test" class="bit-tooltip-action" popover="hint">Test</div>
      CONTENT
    end
  end
end

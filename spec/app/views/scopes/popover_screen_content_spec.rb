# frozen_string_literal: true

require "hanami_helper"

RSpec.describe Terminus::Views::Scopes::PopoverScreenContent do
  using Refinements::Hash

  subject(:scope) { described_class.new locals:, rendering: Terminus::View.new.rendering }

  let(:locals) { Terminus::Aspects::Screens::Placeholder[id: 1].popover_attributes }

  describe "#element_id" do
    it "answers ID" do
      expect(scope.element_id).to eq("popover-screen-1")
    end
  end

  describe "#width" do
    it "answers default" do
      locals.delete :width
      expect(scope.width).to eq(800)
    end
  end

  describe "#height" do
    it "answers default" do
      locals.delete :height
      expect(scope.height).to eq(480)
    end
  end

  describe "#render" do
    it "renders content" do
      assets = Hanami.app[:assets]

      expect(scope.render).to eq(<<~CONTENT)
        <dialog id="popover-screen-1"
                class="bit-popover-content bit-popover-screen"
                popover="auto">
          <figure>
            <img src="#{assets["setup.svg"]}" alt="Placeholder" width="800" height="480" loading="lazy">
            <figcaption>Placeholder</figcaption>
          </figure>

          <p class="brand">
            <img src="#{assets["logo/with_label.svg"]}" alt="Logo with Label" width="150" height="75">
          </p>
        </dialog>
      CONTENT
    end
  end
end

# frozen_string_literal: true

RSpec.shared_examples "an extension contract" do
  it "answers success when valid" do
    expect(contract.call(attributes)).to be_success
  end

  it "answers failure with invalid interval" do
    attributes[:extension].merge! interval: -1, unit: "minute"

    expect(contract.call(attributes).errors.to_h).to eq(
      extension: {
        interval: ["invalid schedule for minute -1."]
      }
    )
  end
end

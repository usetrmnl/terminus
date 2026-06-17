# frozen_string_literal: true

require "hanami_helper"

RSpec.describe Terminus::Actions::Designs::Delete, :db do
  subject(:action) { described_class.new }

  describe "#call" do
    let(:template) { Factory[:screen_template] }

    it "answers success with valid parameters" do
      response = action.call id: template.id
      expect(response.status).to eq(200)
    end

    it "answers unprocessable entity with invalid ID" do
      response = action.call Hash.new
      expect(response.status).to eq(422)
    end
  end
end

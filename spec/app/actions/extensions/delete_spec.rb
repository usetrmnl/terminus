# frozen_string_literal: true

require "hanami_helper"

RSpec.describe Terminus::Actions::Extensions::Delete, :db do
  subject(:action) { described_class.new }

  describe "#call" do
    let(:extension) { Factory[:extension] }

    it "answers success with valid parameters" do
      response = action.call id: extension.id
      expect(response).to have_attributes(status: 200, body: [""])
    end

    it "answers unprocessable entity with invalid ID" do
      response = action.call({id: 13})
      expect(response.status).to eq(422)
    end
  end
end

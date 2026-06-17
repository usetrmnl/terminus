# frozen_string_literal: true

require "hanami_helper"

RSpec.describe Terminus::Actions::Designs::Update, :db do
  subject(:action) { described_class.new }

  describe "#call" do
    let(:template) { Factory[:screen_template] }
    let(:screen) { Factory[:screen, :with_image, model_id: model.id] }
    let(:model) { Factory[:model] }

    let :parameters do
      {
        id: template.id,
        screen_id: screen.id,
        template: {
          label: "Test Update",
          name: "test_update",
          content: "<h1>Update</h1>"
        }
      }
    end

    it "answers updated content" do
      response = Rack::MockRequest.new(action).put "", params: parameters

      expect(response.body).to include("Test Update")
    end

    it "answers error when attribute is missing" do
      parameters[:template].delete :label
      response = Rack::MockRequest.new(action).put "", params: parameters

      expect(response.body).to include("is missing")
    end
  end
end

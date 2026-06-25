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

    it "enqueues job" do
      Sidekiq::Testing.fake! do
        Rack::MockRequest.new(action).put "", params: parameters

        expect(Terminus::Jobs::Screens::Upsert.jobs).to contain_exactly(
          hash_including(
            "args" => [
              model.id,
              {
                "template_id" => template.id,
                "name" => "test_update",
                "label" => "Test Update",
                "content" => "<h1>Update</h1>"
              }
            ]
          )
        )
      end
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

# frozen_string_literal: true

require "hanami_helper"

RSpec.describe Terminus::Views::Scopes::MenuItem do
  subject(:scope) { described_class.new locals:, rendering: Terminus::View.new.rendering(context:) }

  let(:locals) { {label: "Tasks", path: "/tasks"} }
  let(:context) { Terminus::Views::Context.new(request:) }

  let :request do
    Hanami::Action::Request.new env: Rack::MockRequest.env_for(request_path), params: {}
  end

  let(:request_path) { +"/tasks" }

  describe "#classes" do
    it "answers default classes" do
      expect(scope.classes).to eq(:link)
    end

    it "answers custom classes" do
      locals[:classes] = "one two"
      expect(scope.classes).to eq("one two")
    end
  end

  describe "#data" do
    it "answers active state when request and current paths are root" do
      request_path.replace "/"
      locals[:path] = "/"

      expect(scope.data).to eq({state: :active})
    end

    it "answers active state when request path and current path are equal" do
      expect(scope.data).to eq({state: :active})
    end

    it "answers active state when request path starts with current path" do
      request_path.replace "/tasks/1"
      expect(scope.data).to eq({state: :active})
    end

    it "answers empty hash when request path is root" do
      request_path.replace "/"
      expect(scope.data).to eq({})
    end

    it "answers empty hash when current path is root" do
      locals[:path] = "/"
      expect(scope.data).to eq({})
    end

    it "answers empty hash when request path doesn't include current path" do
      request_path.replace "/other"
      expect(scope.data).to eq({})
    end
  end

  describe "#root?" do
    it "answers true when request and current paths are equal" do
      request_path.replace "/"
      locals[:path] = "/"

      expect(scope.root?).to be(true)
    end

    it "answers false when request path isn't root but current path is" do
      request_path.replace "/other"
      locals[:path] = "/"

      expect(scope.root?).to be(false)
    end

    it "answers false when request path is root but current path isn't" do
      request_path.replace "/"
      locals[:path] = "/other"

      expect(scope.root?).to be(false)
    end

    it "answers false when request and current path aren't root" do
      request_path.replace "/other"
      locals[:path] = "/other"

      expect(scope.root?).to be(false)
    end
  end

  describe "#render" do
    it "renders content with state" do
      expect(scope.render).to eq(<<~CONTENT)
        <li class="item">
          <a class="link" data-state="active" href="/tasks">Tasks</a>
        </li>
      CONTENT
    end

    it "renders content without state" do
      request_path.replace "/other"

      expect(scope.render).to eq(<<~CONTENT)
        <li class="item">
          <a class="link" href="/tasks">Tasks</a>
        </li>
      CONTENT
    end
  end
end

# frozen_string_literal: true

RSpec.shared_context "with application dependencies" do
  include_context "with temporary directory"

  let(:app) { Hanami.app }
  let(:settings) { app[:settings] }
  let(:routes) { app[:routes] }
  let(:json_payload) { JSON last_response.body, symbolize_names: true }
  let(:logger) { app[:logger] }

  before do
    allow(settings).to receive_messages(
      api_uri: "https://localhost",
      fonts_root: temp_dir,
      git_tag: "1.2.3",
      git_latest_sha: "abcdefghijkl"
    )
  end
end

# frozen_string_literal: true

require "hanami_helper"
require "trmnl/api"

RSpec.describe Terminus::Aspects::Firmware::Synchronizer, :db do
  subject(:synchronizer) { described_class.new trmnl_api:, downloader: }

  let :trmnl_api do
    instance_double TRMNL::API::Client,
                    firmware_latest: Success(
                      TRMNL::API::Models::Firmware::Latest[
                        url: "https://trmnl-fw.s3.us-east-2.amazonaws.com/FW1.2.3.bin",
                        version: "1.2.3"
                      ]
                    )
  end

  let(:downloader) { instance_double Terminus::Aspects::Downloader, call: download_response }

  let :download_response do
    Success(
      HTTP::Response.new(
        uri: "https://trmnl-fw.s3.us-east-2.amazonaws.com/FW1.2.3.bin",
        body: [123].pack("N"),
        status: 200,
        version: 1.0
      )
    )
  end

  describe "#call" do
    it "answers new record with attachment" do
      response = synchronizer.call.success

      expect(response).to have_attributes(
        version: "1.2.3",
        attachment_attributes: {
          id: /\h{32}\.bin/,
          metadata: {
            filename: "1.2.3.bin",
            height: nil,
            mime_type: "application/octet-stream",
            size: 4,
            width: nil
          },
          storage: "store"
        }
      )
    end

    it "answers existing record" do
      record = Factory[:firmware, version: "1.2.3"]
      expect(synchronizer.call).to be_success(record)
    end

    context "with attachment errors" do
      subject(:synchronizer) { described_class.new trmnl_api:, downloader:, struct: }

      let :struct do
        instance_double Terminus::Structs::Firmware, upload: nil, errors: ["Danger!"], valid?: false
      end

      it "answers failure" do
        expect(synchronizer.call).to be_failure(["Danger!"])
      end
    end

    context "with API client failure" do
      let :trmnl_api do
        instance_double TRMNL::API::Client, firmware_latest: Failure(message: "Danger!")
      end

      it "answers failure" do
        expect(synchronizer.call).to be_failure(message: "Danger!")
      end
    end

    context "with download failure" do
      let :downloader do
        instance_double Terminus::Aspects::Downloader, call: Failure(message: "Danger!")
      end

      it "answers failure" do
        expect(synchronizer.call).to be_failure(message: "Danger!")
      end
    end
  end
end

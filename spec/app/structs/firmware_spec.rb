# frozen_string_literal: true

require "hanami_helper"

RSpec.describe Terminus::Structs::Firmware, :db do
  subject :firmware do
    attachment_data = path.open { Hanami.app[:shrine].upload(it, :store).data }
    repository.create version: "1.2.3", attachment_data:
  end

  let(:repository) { Terminus::Repositories::Firmware.new }
  let(:path) { temp_dir.join("test.bin").tap { it.binwrite [123].pack("N") } }

  include_context "with temporary directory"

  describe "#attachment_attributes" do
    it "answers empty attributes without attachment" do
      firmware = Factory[:firmware]
      expect(firmware.attachment_attributes).to eq({})
    end

    it "answers attributes with attachment" do
      update = Terminus::Repositories::Firmware.new.create version: "0.0.0", attachment_data: {a: 1}
      expect(update.attachment_attributes).to eq(a: 1)
    end
  end

  describe "#attachment_destroy" do
    it "clears store" do
      id = firmware.attachment_id
      firmware.attachment_destroy

      expect(Hanami.app[:shrine].storages[:store].exists?(id)).to be(false)
    end

    it "clears attributes" do
      firmware.attachment_destroy
      expect(firmware.attachment_attributes).to eq({})
    end
  end

  describe "#attachment_id" do
    it "answers ID" do
      expect(firmware.attachment_id).to match(/\h{32}\.bin/)
    end

    it "answers nil when there is no associated attachment" do
      firmware = Factory[:firmware]
      expect(firmware.attachment_uri).to be(nil)
    end
  end

  describe "#attachment_name" do
    it "answers name" do
      expect(firmware.attachment_name).to eq("test.bin")
    end
  end

  describe "#attachment_open" do
    it "yields IO object when given block" do
      firmware.attachment_open { |io| expect(io).to be_a(StringIO) }
    end

    it "answers nil when not given a block" do
      expect(firmware.attachment_open).to be(nil)
    end
  end

  describe "#attachment_size" do
    it "answers size" do
      expect(firmware.attachment_size).to eq(4)
    end
  end

  describe "#attachment_type" do
    it "answers MIME type" do
      expect(firmware.attachment_type).to eq("application/octet-stream")
    end
  end

  describe "#attachment_uri" do
    it "answers URI" do
      expect(firmware.attachment_uri).to match(%r(memory://\h{32}\.bin))
    end
  end

  describe "#attach" do
    it "attaches file" do
      path = temp_dir.join "test.bin"
      path.binwrite [123].pack("N")
      upload = path.open { firmware.attach it }

      expect(upload.data).to match(
        "id" => /\h{32}\.bin/,
        "metadata" => {
          "filename" => "test.bin",
          "height" => nil,
          "size" => 4,
          "mime_type" => "application/octet-stream",
          "width" => nil
        },
        "storage" => "cache"
      )
    end

    it "updates attributes when valid" do
      path = temp_dir.join "test.bin"
      path.binwrite [123].pack("N")
      path.open { firmware.attach it }

      expect(firmware.attachment_attributes).to match(
        id: /\h{32}\.bin/,
        storage: "cache",
        metadata: {
          filename: "test.bin",
          size: 4,
          mime_type: "application/octet-stream",
          width: nil,
          height: nil
        }
      )
    end
  end

  describe "#replace" do
    it "replaces file" do
      instance = path.open { firmware.replace it }

      expect(instance.attachment_attributes).to match(
        id: /\h{32}\.bin/,
        metadata: {
          filename: "test.bin",
          size: 4,
          mime_type: "application/octet-stream",
          width: nil,
          height: nil
        },
        storage: "store"
      )
    end

    it "updates storage ID" do
      id = firmware.attachment_id
      instance = path.open { firmware.replace it }

      expect(id).not_to eq(instance.attachment_id)
    end
  end

  describe "#upload" do
    it "uploads file when valid" do
      path = temp_dir.join "test.bin"
      path.binwrite [123].pack("N")
      upload = path.open { firmware.upload it }

      expect(upload.data).to match(
        "id" => /\h{32}\.bin/,
        "metadata" => {
          "filename" => "test.bin",
          "height" => nil,
          "size" => 4,
          "mime_type" => "application/octet-stream",
          "width" => nil
        },
        "storage" => "store"
      )
    end

    it "updates attributes when valid" do
      path = temp_dir.join "test.bin"
      path.binwrite [123].pack("N")
      path.open { firmware.upload it }

      expect(firmware.attachment_attributes).to match(
        id: /\h{32}\.bin/,
        storage: "store",
        metadata: {
          filename: "test.bin",
          size: 4,
          mime_type: "application/octet-stream",
          width: nil,
          height: nil
        }
      )
    end

    it "doesn't upload file when invalid" do
      upload = firmware.upload StringIO.new

      expect(upload.data).to match(
        "id" => /\h{32}/,
        "metadata" => {
          "filename" => nil,
          "height" => nil,
          "size" => 0,
          "mime_type" => nil,
          "width" => nil
        },
        "storage" => "store"
      )
    end
  end

  describe "#errors" do
    it "answers empty array when valid" do
      firmware.attach StringIO.new([123].pack("N")), metadata: {"filename" => "test.bin"}
      expect(firmware.errors).to eq([])
    end

    it "answers errors when invalid" do
      firmware.attach StringIO.new

      expect(firmware.errors).to eq(
        [
          "type must be one of: application/octet-stream",
          "extension must be one of: bin"
        ]
      )
    end
  end

  describe "#valid?" do
    it "answers true with no errors" do
      path = temp_dir.join "test.bin"
      path.binwrite [123].pack("N")
      path.open { firmware.attach it }

      expect(firmware.valid?).to be(true)
    end

    it "answers false with errors" do
      firmware.attach StringIO.new
      expect(firmware.valid?).to be(false)
    end
  end
end

# frozen_string_literal: true

require "hanami_helper"

RSpec.describe Terminus::Aspects::Firmware::Headers::Transformers::ModelName do
  subject(:transformer) { described_class.new }

  include_context "with application dependencies"

  describe "#call" do
    it "transforms TRMNL OG" do
      headers = {HTTP_MODEL: "og"}
      expect(transformer.call(headers)).to be_success(HTTP_MODEL: "og_plus")
    end

    it "transforms TRMNL OG Gen 2" do
      headers = {HTTP_MODEL: "og_gen2"}
      expect(transformer.call(headers)).to be_success(HTTP_MODEL: "og_plus")
    end

    it "transforms Paper S3" do
      headers = {HTTP_MODEL: "paper_s3"}
      expect(transformer.call(headers)).to be_success(HTTP_MODEL: "m5_paper_s3")
    end

    it "transforms reTerminal E1001" do
      headers = {HTTP_MODEL: "reterminal_e1001"}
      expect(transformer.call(headers)).to be_success(HTTP_MODEL: "seeed_e1001")
    end

    it "transforms reTerminal E1002" do
      headers = {HTTP_MODEL: "reterminal_e1002"}
      expect(transformer.call(headers)).to be_success(HTTP_MODEL: "seeed_e1002")
    end

    it "transforms reTerminal E1003" do
      headers = {HTTP_MODEL: "reterminal_e1003"}
      expect(transformer.call(headers)).to be_success(HTTP_MODEL: "seeed_e1003")
    end

    it "transforms Seeed ESP32C3" do
      headers = {HTTP_MODEL: "seeed_esp32c3"}
      expect(transformer.call(headers)).to be_success(HTTP_MODEL: "seeed_e1001")
    end

    it "transforms Seeed ESP32S3" do
      headers = {HTTP_MODEL: "seeed_esp32s3"}
      expect(transformer.call(headers)).to be_success(HTTP_MODEL: "seeed_e1002")
    end

    it "transforms TRMNL X" do
      headers = {HTTP_MODEL: "x"}
      expect(transformer.call(headers)).to be_success(HTTP_MODEL: "v2")
    end

    it "transforms XIAO ePaper Display" do
      headers = {HTTP_MODEL: "xiao_epaper_display"}
      expect(transformer.call(headers)).to be_success(HTTP_MODEL: "og_plus")
    end

    it "transforms XTEINK X4" do
      headers = {HTTP_MODEL: "xteink_x4"}
      expect(transformer.call(headers)).to be_success(HTTP_MODEL: "xteink_x4")
    end

    context "with unknown name" do
      let(:headers) { {HTTP_MODEL: :bogus} }

      it "answers fallback when name is unknown" do
        expect(transformer.call(headers)).to be_success(HTTP_MODEL: "og_plus")
      end

      it "logs debug message" do
        pattern = /
          DEBUG.+Unknown\sname\swhen\stransforming\sHTTP_MODEL\sheader:\s:bogus\.\s
          Using\sfallback:\sog_plus\.
        /x

        transformer.call headers

        expect(logger.reread).to match(pattern)
      end
    end

    context "with blank name" do
      let(:headers) { {HTTP_MODEL: ""} }

      it "answers fallback name when name is unknown" do
        expect(transformer.call(headers)).to be_success(HTTP_MODEL: "og_plus")
      end

      it "logs debug message" do
        pattern = /
          DEBUG.+Unknown\sname\swhen\stransforming\sHTTP_MODEL\sheader:\s\\"\\"\.\s
          Using\sfallback:\sog_plus\.
        /x

        transformer.call headers

        expect(logger.reread).to match(pattern)
      end
    end

    context "with nil name" do
      let(:headers) { {HTTP_MODEL: nil} }

      it "answers fallback name when name is unknown" do
        expect(transformer.call(headers)).to be_success(HTTP_MODEL: "og_plus")
      end

      it "logs debug message" do
        pattern = /
          DEBUG.+Unknown\sname\swhen\stransforming\sHTTP_MODEL\sheader:\snil\.\s
          Using\sfallback:\sog_plus\.
        /x

        transformer.call headers

        expect(logger.reread).to match(pattern)
      end
    end
  end
end

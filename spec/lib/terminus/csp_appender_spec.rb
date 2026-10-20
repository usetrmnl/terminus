# frozen_string_literal: true

require "hanami_helper"

RSpec.describe Terminus::CSPAppender do
  subject(:appender) { described_class.new }

  describe "#call" do
    let :policy do
      {
        base_uri: "'self'",
        child_src: "'self'",
        connect_src: "'self'",
        default_src: "'none'",
        font_src: "'self'",
        form_action: "'self'",
        frame_ancestors: "'self'",
        frame_src: "'self'",
        img_src: "'self'",
        media_src: "'self'",
        object_src: "'none'",
        script_src: "'self'",
        style_src: "'self'",
        manifest_src: "'self'"
      }
    end

    let :proof do
      {
        base_uri: "'self'",
        child_src: "'self' https://trmnl.com https://a.io https://b.io",
        connect_src: "'self' https://trmnl.com https://a.io https://b.io",
        default_src: "'none'",
        font_src: "'self' https://trmnl.com https://a.io https://b.io",
        form_action: "'self'",
        frame_ancestors: "'self'",
        frame_src: "'self' https://trmnl.com https://a.io https://b.io",
        img_src: "'self' https://trmnl.com https://a.io https://b.io",
        media_src: "'self' https://trmnl.com https://a.io https://b.io",
        object_src: "'none'",
        script_src: "'self' https://trmnl.com https://a.io https://b.io",
        style_src: "'self' https://trmnl.com https://a.io https://b.io",
        manifest_src: "'self'"
      }
    end

    it "appends URIs to allowed keys" do
      expect(appender.call(policy, %w[https://a.io https://b.io])).to eq(proof)
    end

    it "strips trailing spaces" do
      expect(appender.call(policy, ["https://a.io", "https://b.io "])).to eq(proof)
    end
  end
end

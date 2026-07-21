# frozen_string_literal: true

require "rails_helper"

RSpec.describe Koi::Identity::Principal do
  describe "snapshot round-trip" do
    it "rehydrates provider, subject, and scope" do
      principal = described_class.new(
        provider: "komet",
        subject:  "komet-production",
        scope:    "admin/role/event_editor",
      )

      restored = described_class.load(described_class.dump(principal))

      expect(restored)
        .to be_an_instance_of(described_class)
              .and have_attributes(provider: "komet", subject: "komet-production", scope: "admin/role/event_editor")
    end

    it "rehydrates an AWS principal with its identity tags" do
      principal = described_class.new(
        provider: "aws",
        subject:  "arn:aws:iam::123456789012:role/engineer",
        scope:    "admin/user",
        email:    "developer@katalyst.com.au",
      )

      restored = described_class.load(described_class.dump(principal))

      expect(restored)
        .to be_an_instance_of(described_class).and have_attributes(email: "developer@katalyst.com.au")
    end

    it "loads a blank snapshot as nil" do
      expect(described_class.load(nil)).to be_nil
    end
  end
end

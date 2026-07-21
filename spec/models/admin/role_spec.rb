# frozen_string_literal: true

require "rails_helper"

RSpec.describe Admin::Role do
  describe ".materialize" do
    it "creates the row on first access and finds it thereafter", :aggregate_failures do
      expect { described_class.materialize("event_editor") }.to change(described_class, :count).by(1)
      expect { described_class.materialize("event_editor") }.not_to change(described_class, :count)
    end

    it "finds the row when another writer wins the race" do
      existing = described_class.create!(slug: "event_editor")

      expect(described_class.materialize("event_editor")).to eq(existing)
    end
  end

  describe "#last_authenticated_at" do
    it "reports the role's most recent token issuance" do
      role   = create(:admin_role)
      create(:admin_device_authorization, :admin_role, admin_role: role, consumed_at: 2.days.ago)
      latest = create(:admin_device_authorization, :admin_role, admin_role: role, consumed_at: 1.hour.ago)

      expect(role.last_authenticated_at).to be_within(1.second).of(latest.consumed_at)
    end

    it "is nil before first issuance" do
      expect(create(:admin_role).last_authenticated_at).to be_nil
    end
  end

  describe "trust config" do
    before do
      Koi.config.identity = {
        providers: { komet: { issuer: "komet", keys: "env" } },
        members:   {
          komet: { provider: :komet, scope: "admin/role/event_editor", subject: "komet-production" },
        },
      }
    end

    after { Koi.config.instance_variable_set(:@identity, nil) }

    describe "#orphaned?" do
      it "reports a row orphaned once no member grants its slug" do
        expect(described_class.create!(slug: "retired")).to be_orphaned
      end

      it "reports a granted row as current" do
        expect(described_class.materialize("event_editor")).not_to be_orphaned
      end
    end

    describe "#members" do
      it "lists the members granting the role" do
        expect(described_class.materialize("event_editor").members.map(&:name)).to eq(%w[komet])
      end

      it "is empty for an orphaned role" do
        expect(described_class.create!(slug: "retired").members).to be_empty
      end
    end
  end
end

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
end

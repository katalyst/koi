# frozen_string_literal: true

require "rails_helper"

RSpec.describe BackgroundJob do
  describe "#enqueued_at" do
    around do |example|
      Time.use_zone("Australia/Adelaide") { example.run }
    end

    it "returns the payload timestamp in the application time zone" do
      job = instance_double(SolidQueue::Job, arguments: { "enqueued_at" => "2026-08-06T01:00:00Z" })

      expect(described_class.new(job).enqueued_at)
        .to eq(Time.zone.parse("2026-08-06 10:30:00"))
    end
  end
end

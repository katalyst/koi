# frozen_string_literal: true

require "rails_helper"

RSpec.describe RecurringTask do
  describe ".admin_search" do
    subject(:results) { described_class.scope.admin_search(query) }

    let(:task) do
      SolidQueue::RecurringTask.create!(
        key:        "device_authorizations_cleanup",
        class_name: "Admin::DeviceAuthorizationsCleanupJob",
        schedule:   "* * * * *",
        arguments:  [],
      )
    end
    let(:query) { "DEVICEAUTHORIZATIONS" }

    it "searches class_name case-insensitively" do
      expect(results).to include(task)
    end
  end
end

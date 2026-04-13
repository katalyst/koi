# frozen_string_literal: true

require "rails_helper"

RSpec.describe Admin::DeviceAuthorizationsCleanupJob do
  describe "#perform" do
    it "deletes requests older than 7 days" do
      authorization = create(:admin_device_authorization)
      authorization.update_column(:created_at, 8.days.ago) # rubocop:disable Rails/SkipsModelValidations

      expect { described_class.perform_now }.to change(Admin::DeviceAuthorization, :count).by(-1)
    end

    it "retains requests newer than 7 days" do
      authorization = create(:admin_device_authorization)
      authorization.update_column(:created_at, 6.days.ago) # rubocop:disable Rails/SkipsModelValidations

      expect { described_class.perform_now }.not_to change(Admin::DeviceAuthorization, :count)
    end
  end
end

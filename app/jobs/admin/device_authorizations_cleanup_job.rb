# frozen_string_literal: true

module Admin
  class DeviceAuthorizationsCleanupJob < Koi::ApplicationJob
    def perform
      Admin::DeviceAuthorization.where(created_at: ...7.days.ago).delete_all
    end
  end
end

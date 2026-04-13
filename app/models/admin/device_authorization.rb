# frozen_string_literal: true

module Admin
  class DeviceAuthorization < ApplicationRecord
    self.table_name = :admin_device_authorizations

    belongs_to :admin_user, class_name: "Admin::User", optional: true

    enum :status, %w[pending approved denied consumed].index_with(&:to_s)

    validates :device_code_digest, presence: true, uniqueness: true
    validates :request_expires_at, presence: true
    validates :status, presence: true, inclusion: { in: statuses.values }
    validates :user_code, presence: true, uniqueness: true

    def expired?
      request_expires_at <= Time.current
    end

    def issuable?
      approved? && !expired?
    end
  end
end

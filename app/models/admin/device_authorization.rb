# frozen_string_literal: true

module Admin
  class DeviceAuthorization < ApplicationRecord
    EXPIRES_IN = 10.minutes

    self.table_name = :admin_device_authorizations

    belongs_to :admin_user, class_name: "Admin::User", optional: true

    enum :status, %w[pending approved denied consumed].index_with(&:to_s)

    validates :device_code_digest, presence: true, uniqueness: true
    validates :request_expires_at, presence: true
    validates :status, presence: true, inclusion: { in: statuses.values }
    validates :user_code, presence: true, uniqueness: true

    def self.issue!(requested_ip:, user_agent:)
      device_code = SecureRandom.urlsafe_base64(32)

      device_authorization = create!(
        device_code_digest: digest(device_code),
        user_code:          generate_user_code,
        request_expires_at: EXPIRES_IN.from_now,
        requested_ip:,
        user_agent:,
      )

      [device_authorization, device_code]
    end

    def self.digest(device_code)
      Digest::SHA256.hexdigest(device_code)
    end

    def self.generate_user_code
      "#{SecureRandom.alphanumeric(4).upcase}-#{SecureRandom.alphanumeric(4).upcase}"
    end

    def expired?
      request_expires_at <= Time.current
    end

    def issuable?
      approved? && !expired?
    end
  end
end

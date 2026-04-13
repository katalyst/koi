# frozen_string_literal: true

module Admin
  class DeviceAuthorization < ApplicationRecord
    EXPIRES_IN = 10.minutes

    class TokenError < StandardError
      attr_reader :code

      def initialize(code)
        @code = code
        super
      end
    end

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

    def self.issue_access_token!(device_code:, token_expires_in: 12.hours)
      device_authorization = find_by(device_code_digest: digest(device_code.to_s))
      raise TokenError.new("invalid_grant") unless device_authorization

      device_authorization.with_lock do
        device_authorization.reload

        if (error = device_authorization.token_error)
          raise TokenError.new(error)
        end

        access_token = device_authorization.admin_user.generate_token_for(:api_access)
        device_authorization.consume!(token_expires_in:)

        {
          access_token:,
          token_type:   "Bearer",
          expires_in:   token_expires_in.to_i,
        }
      end
    end

    def expired?
      request_expires_at <= Time.current
    end

    def issuable?
      approved? && !expired?
    end

    def token_error
      return "authorization_pending" if pending?
      return "access_denied" if denied?

      "invalid_grant" if consumed? || expired?
    end

    def consume!(token_expires_in:)
      update!(
        status:           "consumed",
        consumed_at:      Time.current,
        token_expires_at: token_expires_in.from_now,
      )
    end

    def approve!(admin_user:)
      update!(
        status:      "approved",
        approved_at: Time.current,
        admin_user:,
      )
    end

    def deny!(admin_user:)
      update!(
        status:     "denied",
        admin_user:,
      )
    end

    def actionable?
      pending? && !expired?
    end
  end
end

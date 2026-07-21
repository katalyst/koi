# frozen_string_literal: true

module Admin
  class DeviceAuthorization < ApplicationRecord
    REQUEST_EXPIRES_IN = 10.minutes
    TOKEN_EXPIRES_IN   = 1.hour

    class TokenError < StandardError
      attr_reader :code

      def initialize(code)
        @code = code
        super
      end
    end

    self.table_name = :admin_device_authorizations

    enum :status, %w[pending approved denied consumed].index_with(&:to_s)

    generates_token_for(:api_access, expires_in: TOKEN_EXPIRES_IN) do
      admin_user&.last_sign_in_at || admin_role&.tokens_revoked_at
    end

    validates :status, presence: true, inclusion: { in: statuses.values }

    with_options(if: :pending?) do
      validates :device_code_digest, presence: true, uniqueness: true
      validates :user_code, presence: true, uniqueness: true
      validates :request_expires_at, presence: true
    end

    belongs_to :admin_user,
               class_name:    "Admin::User",
               counter_cache: true,
               inverse_of:    :device_authorizations,
               optional:      true

    belongs_to :admin_role,
               class_name: "Admin::Role",
               inverse_of: :device_authorizations,
               optional:   true

    # Snapshot of the verified principal, as captured by `issue_token!`.
    serialize :principal, coder: Koi::Identity::Principal
    attr_readonly :principal

    # Creates a new un-approved request.
    def self.create_request!(requested_ip:, user_agent:)
      device_code = SecureRandom.urlsafe_base64(32)

      device_authorization = create!(
        device_code_digest: digest(device_code),
        user_code:          generate_user_code,
        request_expires_at: REQUEST_EXPIRES_IN.from_now,
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

    # Consume an approved request, returns the issued token payload.
    def self.consume_request!(device_code:)
      device_authorization = find_by(device_code_digest: digest(device_code.to_s))
      raise TokenError.new("invalid_grant") unless device_authorization

      device_authorization.with_lock do
        device_authorization.reload

        if (error = device_authorization.token_error)
          raise TokenError.new(error)
        end

        device_authorization.consume!
      end
    end

    # Issue a new token directly from a validated assertion, returns the issued token payload.
    def self.issue_token!(principal:, **)
      case principal.scope
      when "admin/user"
        admin_user = Admin::User.find_by(principal.attributes_for_find)

        unless admin_user
          Rails.logger.warn("Koi::Identity rejected #{principal}: no matching admin user")
          raise JWT::VerificationError, "unknown user for #{principal}"
        end

        new(admin_user:, principal:, **).consume!
      when %r{\Aadmin/role/(?<slug>[a-z0-9_]+)\z}
        admin_role = Admin::Role.materialize(Regexp.last_match(:slug))

        new(admin_role:, principal:, **).consume!
      else
        raise ArgumentError, "unknown scope #{principal.scope.inspect}"
      end
    end

    # @return [Admin::User, Admin::Role, nil]
    def actor
      admin_user || admin_role
    end

    def expired?
      request_expires_at.present? && request_expires_at <= Time.current
    end

    def issuable?
      approved? && !expired?
    end

    def token_error
      return "authorization_pending" if pending?
      return "access_denied" if denied?

      "invalid_grant" if consumed? || expired?
    end

    def consume!
      update!(
        status:           "consumed",
        consumed_at:      Time.current,
        token_expires_at: TOKEN_EXPIRES_IN.from_now,
      )

      token_payload
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

    private

    def token_payload(access_token = generate_token_for(:api_access))
      {
        access_token:,
        token_type:   "Bearer",
        expires_in:   (token_expires_at - Time.current).round,
      }
    end
  end
end

# frozen_string_literal: true

module Admin
  class User < ApplicationRecord
    include Koi::Model::Archivable
    include Koi::Model::OTP

    def self.model_name
      ActiveModel::Name.new(self, nil, "AdminUser")
    end

    self.table_name = :admins

    attribute :password_login, :string
    enum :password_login, { none: "none", password_only: "password_only", mfa: "mfa" }, prefix: true

    # disable validations for password_digest – we don't require a password (i.e. passkey only user)
    has_secure_password validations: false

    normalizes :email, with: ->(e) { e.strip.downcase }

    validates :name, :email, presence: true
    validates :email, uniqueness: true, format: { with: URI::MailTo::EMAIL_REGEXP }

    generates_token_for(:password_reset, expires_in: 30.minutes) { last_sign_in_at }

    has_many :credentials,
             class_name: "Admin::Credential",
             dependent:  :destroy,
             inverse_of: :admin
    has_many :device_authorizations,
             class_name: "Admin::DeviceAuthorization",
             dependent:  :destroy,
             inverse_of: :admin_user
    has_many :sessions,
             class_name: "Admin::Session",
             dependent:  :destroy,
             inverse_of: :admin

    scope :alphabetical, -> { order(name: :asc) }

    if "PgSearch::Model".safe_constantize
      include PgSearch::Model

      pg_search_scope :admin_search, against: %i[email name], using: { tsearch: { prefix: true } }
    else
      scope :admin_search, ->(query) do
        where("email LIKE :query OR name LIKE :query", query: "%#{query}%")
      end
    end

    scope :has_password_login, ->(type) do
      case type&.to_sym
      when :password_only
        where.not(password_digest: "").where(otp_secret: nil)
      when :mfa
        where.not(password_digest: "").where.not(otp_secret: nil)
      else
        where(password_digest: "")
      end
    end

    scope :has_otp, ->(otp) do
      if otp
        where.not(otp_secret: nil)
      else
        where(otp_secret: nil)
      end
    end

    scope :has_passkey, ->(passkey) do
      if passkey
        where(id: Admin::Credential.select(:admin_id))
      else
        where.not(id: Admin::Credential.select(:admin_id))
      end
    end

    def passkey?
      credentials.any?
    end
    alias passkey passkey?

    # Describe the last time the user signed in or out. For self-reflection, excludes the current session.
    #
    # @return [ActiveSupport::TimeWithZone, nil] the last time the user was active
    def last_active_at
      [last_sign_in_at, last_sign_out_at].compact.max
    end

    # Describe the last time the user signed in or out, excluding the current session (for self).
    #
    # @return [ActiveSupport::TimeWithZone, nil] the last time the user was active
    def previous_active_at(current_session = Koi::Current.session)
      [last_sign_out_at, sessions.where.not(id: current_session.id).maximum(:created_at)].compact.max
    end

    def password_login
      if password_digest.blank?
        :none
      elsif otp_secret.nil?
        :password_only
      else
        :mfa
      end
    end

    def to_s
      name
    end
  end
end

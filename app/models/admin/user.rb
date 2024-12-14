# frozen_string_literal: true

module Admin
  class User < ApplicationRecord
    include Koi::Model::Archivable
    include Koi::Model::OTP

    def self.model_name
      ActiveModel::Name.new(self, nil, "Admin")
    end

    # disable validations for password_digest
    has_secure_password validations: false

    has_many :credentials, inverse_of: :admin, class_name: "Admin::Credential", dependent: :destroy

    validates :name, :email, presence: true
    validates :email, uniqueness: true, format: { with: URI::MailTo::EMAIL_REGEXP }

    scope :alphabetical, -> { order(name: :asc) }

    if "PgSearch::Model".safe_constantize
      include PgSearch::Model

      pg_search_scope :admin_search, against: %i[email name], using: { tsearch: { prefix: true } }
    else
      scope :admin_search, ->(query) do
        where("email LIKE :query OR name LIKE :query", query: "%#{query}%")
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

    def passkey
      credentials.any?
    end
    alias passkey? passkey
  end
end

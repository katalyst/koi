# frozen_string_literal: true

module Admin
  class User < ApplicationRecord
    include Koi::Model::Archivable

    def self.model_name
      ActiveModel::Name.new(self, nil, "Admin")
    end

    # disable validations for password_digest, as we don't want to validate the password on create
    has_secure_password validations: false
    # validate password on update if no credentials are present or password is present
    validate :validate_password, on: :update, if: -> { credentials.blank? || password.present? }

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

    def validate_password
      errors.add(:password, :blank) if password_digest.blank?

      if password.present? && password.bytesize > ActiveModel::SecurePassword::MAX_PASSWORD_LENGTH_ALLOWED
        record.errors.add(:password, :password_too_long)
      end
    end
  end
end

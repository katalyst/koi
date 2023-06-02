# frozen_string_literal: true

module Admin
  class User < ApplicationRecord
    include Koi::Model::Archivable

    def self.model_name
      ActiveModel::Name.new(self, nil, "Admin")
    end

    has_secure_password :password

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

    # TODO(sfn) remove once Rails 7.1 is released
    # https://edgeapi.rubyonrails.org/classes/ActiveRecord/SecurePassword/ClassMethods.html#method-i-authenticate_by
    # rubocop:disable Metrics/PerceivedComplexity
    def self.authenticate_by(attributes)
      passwords, identifiers = attributes.to_h.partition do |name, _value|
        !has_attribute?(name) && has_attribute?("#{name}_digest")
      end.map(&:to_h)

      raise ArgumentError, "One or more password arguments are required" if passwords.empty?
      raise ArgumentError, "One or more finder arguments are required" if identifiers.empty?

      if (record = find_by(identifiers))
        record if passwords.count { |name, value| record.public_send(:"authenticate_#{name}", value) } == passwords.size
      else
        new(passwords)
        nil
      end
    end

    # rubocop:enable Metrics/PerceivedComplexity
  end
end

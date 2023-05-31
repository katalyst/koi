# frozen_string_literal: true

class AdminUser < ApplicationRecord
  class << self
    def model_name
      ActiveModel::Name.new(self, nil, "Admin")
    end
  end

  has_secure_password :password

  has_many :credentials, class_name: "AdminCredential", dependent: :destroy

  before_validation :set_default_values

  validates :first_name, :last_name, :email, :role, presence: true
  validates :email, uniqueness: true, format: { with: URI::MailTo::EMAIL_REGEXP }

  ROLES = %w[Super Admin].freeze

  validates :role, inclusion: ROLES

  scope :alphabetical, -> { order("LOWER(admins.last_name)", "LOWER(admins.first_name)") }

  if "PgSearch::Model".safe_constantize
    include PgSearch::Model

    pg_search_scope :admin_search, against: %i[email first_name last_name], using: { tsearch: { prefix: true } }
  else
    scope :admin_search, ->(query) do
      where("email LIKE :query OR first_name LIKE :query OR last_name LIKE :query", query: "%#{query}%")
    end
  end

  def to_s
    name
  end

  def is?(value)
    role.eql?(value)
  end

  def self.super_admin
    "Super"
  end

  def super_admin?
    is? self.class.super_admin
  end

  def name=(value)
    self.first_name, self.last_name = value.split(" ", 2)
  end

  def name
    "#{first_name} #{last_name}"
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

  private

  def set_default_values
    self.role ||= "Admin"
  end
end

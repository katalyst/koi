# frozen_string_literal: true

class AdminUser < ApplicationRecord
  class << self
    def model_name
      ActiveModel::Name.new(self, nil, "Admin")
    end
  end

  devise :database_authenticatable, :recoverable,
         :rememberable, :trackable, :validatable

  before_validation :set_default_values

  validates :first_name, :last_name, :email, :role, presence: true

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
    "#{first_name} #{last_name}"
  end

  def is?(value)
    role.eql?(value)
  end

  def self.god
    "Super"
  end

  def god?
    is? self.class.god
  end

  private

  def set_default_values
    self.role ||= "Admin"
  end
end

# frozen_string_literal: true

class AdminUser < ApplicationRecord
  include HasCrud::ActiveRecord

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

  has_crud searchable: %i[id first_name last_name email role],
           ajaxable:   true

  crud.config do
    fields role: { type: :roles }
    config :admin do
      index fields: %i[id first_name last_name email role]
      form  fields: %i[first_name last_name email role password password_confirmation]
      show  fields: %i[first_name last_name email role sign_in_count current_sign_in_ip
                       last_sign_in_at last_sign_in_ip]
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

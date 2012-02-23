class Admin < ActiveRecord::Base
  devise :database_authenticatable, :recoverable,
         :rememberable, :trackable, :validatable

  attr_accessible :email, :password, :password_confirmation,
                  :remember_me, :first_name, :last_name, :role

  before_validation :set_default_values

  validates :first_name, :last_name, :email, :role, presence: true

  ROLES = ["Super", "Admin"]

  has_crud searchable: [:id, :first_name, :last_name, :email, :role],
           ajaxable: true, settings: false

  crud.config do
    fields role: { type: :roles }
    config :admin do
      index fields: [:id, :first_name, :last_name, :email, :role]
      form  fields: [:first_name, :last_name, :email, :role, :password, :password_confirmation]
      show  fields: [:first_name, :last_name, :email, :role, :sign_in_count, :current_sign_in_ip,
                     :last_sign_in_at, :last_sign_in_ip]
    end
  end

  def to_s
    "#{first_name} #{last_name}"
  end

  def is?(value)
    role.eql?(value)
  end

  def god?
    is?("Super")
  end

private

  def set_default_values
    self.role ||= "Admin"
  end

  def password_required?
    new_record? || destroyed? || password.present? || password_confirmation.present?
  end
end

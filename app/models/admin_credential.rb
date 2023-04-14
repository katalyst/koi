# frozen_string_literal: true

class AdminCredential < ApplicationRecord
  belongs_to :admin, class_name: "AdminUser", inverse_of: :credentials

  validates :external_id, :public_key, :nickname, :sign_count, presence: true
  validates :external_id, uniqueness: true
  validates :sign_count,
            numericality: { only_integer: true, greater_than_or_equal_to: 0 }
end

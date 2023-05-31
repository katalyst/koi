# frozen_string_literal: true

module Admin
  class Credential < ApplicationRecord
    self.table_name = :admin_credentials

    belongs_to :admin, class_name: "Admin::User", inverse_of: :credentials

    validates :external_id, :public_key, :nickname, :sign_count, presence: true
    validates :external_id, uniqueness: true
    validates :sign_count,
              numericality: { only_integer: true, greater_than_or_equal_to: 0 }
  end
end

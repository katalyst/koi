# frozen_string_literal: true

module Admin
  # Persists browser authentication state for an admin user.
  class Session < ApplicationRecord
    self.table_name = :admin_sessions

    belongs_to :admin, class_name: "Admin::User", inverse_of: :sessions
  end
end

# frozen_string_literal: true

module Admin
  # Persists browser authentication state for an admin user.
  class Session < ApplicationRecord
    COOKIE_NAME = :koi_admin_session_id

    self.table_name = :admin_sessions

    belongs_to :admin, class_name: "Admin::User", inverse_of: :sessions

    def self.from_request(request)
      session_id = request.cookie_jar.signed[COOKIE_NAME]
      return if session_id.blank?

      admin_session = includes(:admin).find_by(id: session_id)
      return if admin_session&.admin.blank?

      admin_session
    end
  end
end

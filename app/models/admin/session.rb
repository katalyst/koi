# frozen_string_literal: true

module Admin
  class Session < ApplicationRecord
    self.table_name = :admin_sessions

    belongs_to :admin, class_name: "Admin::User", inverse_of: :sessions
  end
end

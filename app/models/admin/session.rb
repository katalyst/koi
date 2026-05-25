# frozen_string_literal: true

module Admin
  class Session < ApplicationRecord
    self.table_name = :admin_sessions

    belongs_to :admin,
               class_name:    "Admin::User",
               counter_cache: true,
               inverse_of:    :sessions

    after_create_commit :record_sign_in!
    after_destroy_commit :record_sign_out!

    private

    def record_sign_in!
      admin.update!(
        last_sign_in_at: created_at,
        last_sign_in_ip: ip_address,
        sign_in_count:   admin.sign_in_count + 1,
      )
    end

    def record_sign_out!
      return if admin.destroyed?

      admin.update!(last_sign_out_at: Time.current)
    rescue ActiveRecord::RecordNotFound
      nil
    end
  end
end

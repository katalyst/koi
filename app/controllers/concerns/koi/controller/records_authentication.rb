# frozen_string_literal: true

module Koi
  module Controller
    module RecordsAuthentication
      def update_last_sign_in(admin_user)
        return if admin_user.current_sign_in_at.blank?

        admin_user.last_sign_in_at = admin_user.current_sign_in_at
        admin_user.last_sign_in_ip = admin_user.current_sign_in_ip
      end

      def record_sign_in!(admin_user)
        update_last_sign_in(admin_user)

        admin_user.current_sign_in_at = Time.current
        admin_user.current_sign_in_ip = request.remote_ip
        admin_user.sign_in_count += 1

        admin_user.save!
      end

      def record_sign_out!(admin_user)
        return unless admin_user

        update_last_sign_in(admin_user)

        admin_user.current_sign_in_at = nil
        admin_user.current_sign_in_ip = nil

        admin_user.save!
      end
    end
  end
end

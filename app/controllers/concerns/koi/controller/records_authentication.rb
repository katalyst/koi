# frozen_string_literal: true

module Koi
  module Controller
    module RecordsAuthentication
      def create_admin_session!(admin_user)
        sign_in_at = Time.current

        update_last_sign_in(admin_user)

        admin_user.current_sign_in_at = sign_in_at
        admin_user.current_sign_in_ip = request.remote_ip
        admin_user.sign_in_count += 1

        admin_user.save!

        session[:admin_user_id] = admin_user.id
        session[:admin_user_signed_in_at] = sign_in_at.iso8601(6)
      end

      def destroy_admin_session!(admin_user)
        session[:admin_user_id] = nil
        session[:admin_user_signed_in_at] = nil

        return unless admin_user

        sign_out_at = Time.current

        update_last_sign_in(admin_user)

        admin_user.last_sign_out_at = sign_out_at
        admin_user.current_sign_in_at = nil
        admin_user.current_sign_in_ip = nil

        admin_user.save!
      end

      private

      def update_last_sign_in(admin_user)
        return if admin_user.current_sign_in_at.blank?

        admin_user.last_sign_in_at = admin_user.current_sign_in_at
        admin_user.last_sign_in_ip = admin_user.current_sign_in_ip
      end
    end
  end
end

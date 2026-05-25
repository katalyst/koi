# frozen_string_literal: true

module Koi
  module Controller
    module RecordsAuthentication
      def create_admin_session!(admin_user)
        sign_in_at = Time.current

        update_last_sign_in(admin_user)

        admin_user.current_sign_in_at = sign_in_at
        admin_user.current_sign_in_ip = request.remote_ip
        admin_user.sign_in_count     += 1

        admin_user.save!

        admin_user.sessions.create!(user_agent: request.user_agent, ip_address: request.remote_ip).tap do |session|
          Koi::Current.session                        = session
          cookies.signed.permanent[:admin_session_id] = { value: session.id, httponly: true, same_site: :lax }
        end
      end

      def destroy_admin_sessions!(admin_user)
        sign_out_at = Time.current

        admin_user.device_authorizations.destroy_all
        admin_user.sessions.destroy_all

        update_last_sign_in(admin_user)

        admin_user.last_sign_out_at   = sign_out_at
        admin_user.current_sign_in_at = nil
        admin_user.current_sign_in_ip = nil

        admin_user.save!

        Koi::Current.session = nil
        cookies.delete(:admin_session_id)
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

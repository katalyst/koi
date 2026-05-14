# frozen_string_literal: true

module Koi
  module Controller
    module RecordsAuthentication
      ADMIN_SESSION_COOKIE = :koi_admin_session_id

      def create_admin_session!(admin_user = Koi::Current.admin_user)
        sign_in_at = Time.current

        update_last_sign_in(admin_user)

        admin_user.current_sign_in_at = sign_in_at
        admin_user.current_sign_in_ip = request.remote_ip
        admin_user.sign_in_count += 1

        admin_user.save!

        Koi::Current.admin_session = admin_user.sessions.create!(
          ip_address: request.remote_ip,
          user_agent: request.user_agent,
        )

        cookies.signed.permanent[ADMIN_SESSION_COOKIE] = {
          value:     Koi::Current.admin_session.id,
          httponly:  true,
          same_site: :lax,
        }
      end

      def destroy_admin_session!(admin_user = Koi::Current.admin_user)
        Koi::Current.admin_session&.destroy!
        Koi::Current.admin_session = nil

        cookies.delete(ADMIN_SESSION_COOKIE)

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
